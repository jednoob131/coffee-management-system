package entity;

import jakarta.persistence.*;

@Entity
@Table(name = "Drinks")
public class Drink {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "drink_id")
    private int drinkId;

    @Column(name = "drink_name")
    private String drinkName;

    @Column(name = "price")
    private double price;

    @Column(name = "category")
    private String category;

    @Column(name = "status")
    private boolean status;

    @Column(name = "image")
    private String image;

    public int getDrinkId() { return drinkId; }
    public void setDrinkId(int id) { this.drinkId = id; }

    public String getDrinkName() { return drinkName; }
    public void setDrinkName(String n) { this.drinkName = n; }

    public double getPrice() { return price; }
    public void setPrice(double p) { this.price = p; }

    public String getCategory() { return category; }
    public void setCategory(String c) { this.category = c; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean s) { this.status = s; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
}