package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.User;
import java.util.List;

public interface UserService {

    User getUserById(Long id);

    List<User> listAllUsers();

    User updateUser(User user);

    void deleteUser(Long id);

    void blockUser(Long id);

    void unblockUser(Long id);
}
