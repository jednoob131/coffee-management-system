package entity;

import jakarta.persistence.*;

@Entity
@Table(name = "Users")
public class User {

    @Id
    @Column(name = "username")
    private String username;

    @Column(name = "password")
    private String password;

    @Column(name = "fullname")
    private String fullname;

    @Column(name = "role")
    private boolean role;

    @Column(name = "email")
    private String email;

    @Column(name = "phone")
    private String phone;

    @Column(name = "is_deleted")
    private boolean isDeleted = false;

    public String getUsername() { return username; }
    public void setUsername(String u) { this.username = u; }

    public String getPassword() { return password; }
    public void setPassword(String p) { this.password = p; }

    public String getFullname() { return fullname; }
    public void setFullname(String f) { this.fullname = f; }

    public boolean isRole() { return role; }
    public void setRole(boolean r) { this.role = r; }

    public String getEmail() { return email; }
    public void setEmail(String e) { this.email = e; }

    public String getPhone() { return phone; }
    public void setPhone(String p) { this.phone = p; }

    public boolean isDeleted() { return isDeleted; }
    public void setDeleted(boolean d) { this.isDeleted = d; }
}
