package Dao;

import java.util.List;
import entity.BillDetail;

public interface BillDetailDao {
    void insert(BillDetail detail);
    void delete(int detailId);
    List<BillDetail> findByBillId(int billId);
}
