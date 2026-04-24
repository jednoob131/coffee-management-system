package entity;

import jakarta.persistence.*;

@Entity
@Table(name = "BillDetails")
public class BillDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "detail_id")
    private int detailId;

    @Column(name = "bill_id")
    private int billId;

    @Column(name = "drink_id")
    private int drinkId;

    @Column(name = "quantity")
    private int quantity;

    @Column(name = "price")
    private double price;

    public int getDetailId() { return detailId; }
    public void setDetailId(int id) { this.detailId = id; }

    public int getBillId() { return billId; }
    public void setBillId(int b) { this.billId = b; }

    public int getDrinkId() { return drinkId; }
    public void setDrinkId(int d) { this.drinkId = d; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int q) { this.quantity = q; }

    public double getPrice() { return price; }
    public void setPrice(double p) { this.price = p; }
}
