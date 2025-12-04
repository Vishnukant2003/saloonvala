package com.salonvala.salonmanagement.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Serve uploaded gallery images
        String galleryPath = Paths.get("uploads/gallery").toAbsolutePath().toString();
        registry.addResourceHandler("/uploads/gallery/**")
                .addResourceLocations("file:" + galleryPath + "/");
        
        // Serve uploaded staff photos
        String staffPath = Paths.get("uploads/staff").toAbsolutePath().toString();
        registry.addResourceHandler("/uploads/staff/**")
                .addResourceLocations("file:" + staffPath + "/");
    }

    @Override
    public void configurePathMatch(org.springframework.web.servlet.config.annotation.PathMatchConfigurer configurer) {
        // Ensure API endpoints are not treated as static resources
        configurer.setUseTrailingSlashMatch(false);
    }
}
