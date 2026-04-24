package Daoimpl;

import java.util.List;
import Dao.BillDetailDao;
import entity.BillDetail;
import jakarta.persistence.*;
import util.JpaUtil;

public class BillDetailDaoImpl implements BillDetailDao {

    @Override
    public void insert(BillDetail detail) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try { t.begin(); em.persist(detail); t.commit(); }
        catch (Exception e) { t.rollback(); }
        finally { em.close(); }
    }

    @Override
    public void delete(int detailId) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try {
            t.begin();
            BillDetail d = em.find(BillDetail.class, detailId);
            if (d != null) em.remove(d);
            t.commit();
        } catch (Exception e) { t.rollback(); }
        finally { em.close(); }
    }

    @Override
    public List<BillDetail> findByBillId(int billId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<BillDetail> q = em.createQuery(
                "SELECT d FROM BillDetail d WHERE d.billId = :billId", BillDetail.class);
            q.setParameter("billId", billId);
            return q.getResultList();
        } finally { em.close(); }
    }
}
