package com.haui.Demotesting.service;

import com.haui.Demotesting.entity.User;

import java.util.List;
import java.util.Optional;


public interface IUserSevice {
    //lấy danh sách tất cả người dùng
    List<User>  getAllUsers();

    //Lấy thông tin người dùng theo id
    Optional<User> getUserById(int id);

    //Thêm mới người dùng
    User createUser(User user);

    //Cập nhật thông tin người dùng
    User updateUser(int id, User user);

    //Xóa người dùng theo id
    void deleteUser(int id);

}
