package com.haui.Demotesting.controller;

import com.haui.Demotesting.entity.User;
import com.haui.Demotesting.service.IUserSevice;
import com.haui.Demotesting.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/v1/users")

public class UserController {
    @Autowired
    private IUserSevice userService;

    @GetMapping
    public List<User> getAllUsers(){
        List<User> users = userService.getAllUsers();
        return ResponseEntity.ok(users).getBody();

    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Integer id){
        return userService.getUserById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    //Thêm mới người dùng
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User newUser = userService.createUser(user);
        return ResponseEntity.ok(newUser);
    }

    //Cập nhật thông tin người dùng
    @PutMapping("/{id}")
    public ResponseEntity<User> update(@PathVariable int id, @RequestBody User user){
        try {
            User update = userService.updateUser(id,user);
            return ResponseEntity.ok(update);
        }catch (RuntimeException e){
            return ResponseEntity.notFound().build();
        }
    }

    //xóa người dùng theo id
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable int id){
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
