package Dao;

import java.util.List;
import entity.User;

public interface UserDao {

    void insert(User user);

    void update(User user);

    void delete(String username);

    User findByUsername(String username);

    List<User> findAll();

    long countStaff();

    User findByEmail(String email);

    List<User> findAllByEmail(String email);

    void updatePassword(String username, String password);

}