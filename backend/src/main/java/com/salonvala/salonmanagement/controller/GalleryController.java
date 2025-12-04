package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.SalonGallery;
import com.salonvala.salonmanagement.repository.SalonGalleryRepository;
import com.salonvala.salonmanagement.service.SalonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/salon/gallery")
@CrossOrigin
public class GalleryController {

    @Autowired
    private SalonGalleryRepository galleryRepository;

    @Autowired
    private SalonService salonService;

    private static final String UPLOAD_DIR = "uploads/gallery/";

    // Create upload directory if it doesn't exist
    private void ensureUploadDirExists() {
        try {
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadImage(
            @RequestPart("salonId") String salonIdStr,
            @RequestPart("image") MultipartFile file) {

        try {
            // Validate file
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest().body(new ApiResponse("File is empty", null));
            }

            // Parse salonId from string
            Long salonId;
            try {
                salonId = Long.parseLong(salonIdStr);
            } catch (NumberFormatException e) {
                return ResponseEntity.badRequest().body(new ApiResponse("Invalid salon ID", null));
            }

            Salon salon = salonService.getSalonById(salonId);
            ensureUploadDirExists();

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
                : ".jpg";
            String filename = UUID.randomUUID().toString() + extension;

            // Save file
            Path filePath = Paths.get(UPLOAD_DIR + filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Create gallery entry
            SalonGallery gallery = new SalonGallery();
            gallery.setSalon(salon);
            gallery.setImageUrl("/uploads/gallery/" + filename);
            galleryRepository.save(gallery);

            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", gallery.getImageUrl());
            response.put("imageId", gallery.getId().toString());

            return ResponseEntity.ok(new ApiResponse("File uploaded successfully", response));
        } catch (org.springframework.web.multipart.MaxUploadSizeExceededException e) {
            return ResponseEntity.badRequest().body(new ApiResponse("File size exceeds maximum limit (100MB)", null));
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(new ApiResponse("Failed to upload file: " + e.getMessage(), null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(new ApiResponse("Failed to upload file: " + e.getMessage(), null));
        }
    }

    @GetMapping("/{salonId}")
    public ResponseEntity<?> getGallery(@PathVariable Long salonId) {
        try {
            Salon salon = salonService.getSalonById(salonId);
            List<SalonGallery> gallery = galleryRepository.findBySalon(salon);
            List<Map<String, Object>> galleryData = gallery.stream()
                    .map(img -> {
                        Map<String, Object> item = new HashMap<>();
                        item.put("id", img.getId());
                        item.put("imageUrl", img.getImageUrl());
                        return item;
                    })
                    .collect(Collectors.toList());
            return ResponseEntity.ok(galleryData);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiResponse("Failed to fetch gallery: " + e.getMessage(), null));
        }
    }

    @DeleteMapping("/{imageId}")
    public ResponseEntity<?> deleteImage(@PathVariable Long imageId) {
        try {
            SalonGallery gallery = galleryRepository.findById(imageId)
                    .orElseThrow(() -> new IllegalArgumentException("Image not found"));

            // Delete file from filesystem
            try {
                String imageUrl = gallery.getImageUrl();
                if (imageUrl != null && imageUrl.startsWith("/uploads/")) {
                    Path filePath = Paths.get(imageUrl.substring(1)); // Remove leading /
                    Files.deleteIfExists(filePath);
                }
            } catch (IOException e) {
                // Log error but continue with database deletion
                System.err.println("Failed to delete file: " + e.getMessage());
            }

            galleryRepository.delete(gallery);
            return ResponseEntity.ok(new ApiResponse("Image deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiResponse("Failed to delete image: " + e.getMessage(), null));
        }
    }
}

