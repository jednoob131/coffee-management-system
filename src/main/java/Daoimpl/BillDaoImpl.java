package Daoimpl;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

import Dao.BillDao;
import entity.Bill;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import util.JpaUtil;

public class BillDaoImpl implements BillDao {

    @Override
    public void insert(Bill bill) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try {
            t.begin();
            em.persist(bill);
            t.commit();
        } catch (Exception e) {
            if (t.isActive()) t.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    @Override
    public void update(Bill bill) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try {
            t.begin();
            em.merge(bill);
            t.commit();
        } catch (Exception e) {
            if (t.isActive()) t.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    @Override
    public void delete(int billId) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try {
            t.begin();
            Bill b = em.find(Bill.class, billId);
            if (b != null) {
                em.remove(b);
            }
            t.commit();
        } catch (Exception e) {
            if (t.isActive()) t.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    @Override
    public Bill findById(int billId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.find(Bill.class, billId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public Bill findByOrderCode(String orderCode) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Bill> q = em.createQuery(
                    "SELECT b FROM Bill b WHERE b.orderCode = :orderCode",
                    Bill.class
            );
            q.setParameter("orderCode", orderCode);
            List<Bill> list = q.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public List<Bill> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT b FROM Bill b ORDER BY b.createdDate DESC",
                    Bill.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Bill> findByUsername(String username) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Bill> q = em.createQuery(
                    "SELECT b FROM Bill b WHERE b.username = :u ORDER BY b.createdDate DESC",
                    Bill.class
            );
            q.setParameter("u", username);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Bill> findPaidByUsername(String username) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Bill> q = em.createQuery(
                    "SELECT b FROM Bill b WHERE b.username = :u AND b.paymentStatus = 'PAID' ORDER BY b.createdDate DESC",
                    Bill.class
            );
            q.setParameter("u", username);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public int insertAndGetId(Bill bill) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try {
            t.begin();
            em.persist(bill);
            t.commit();
            return bill.getBillId();
        } catch (Exception e) {
            if (t.isActive()) t.rollback();
            e.printStackTrace();
            return -1;
        } finally {
            em.close();
        }
    }

    @Override
    public List<Bill> findByDateAndUsername(Date from, Date to, String username) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Bill> q = em.createQuery(
                    "SELECT b FROM Bill b WHERE b.username = :u AND b.createdDate >= :from AND b.createdDate < :to ORDER BY b.createdDate DESC",
                    Bill.class
            );
            q.setParameter("u", username);
            q.setParameter("from", new Timestamp(from.getTime()));
            q.setParameter("to", new Timestamp(to.getTime()));
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Bill> findPaidByDateAndUsername(Date from, Date to, String username) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Bill> q = em.createQuery(
                    "SELECT b FROM Bill b WHERE b.username = :u AND b.paymentStatus = 'PAID' AND b.createdDate >= :from AND b.createdDate < :to ORDER BY b.createdDate DESC",
                    Bill.class
            );
            q.setParameter("u", username);
            q.setParameter("from", new Timestamp(from.getTime()));
            q.setParameter("to", new Timestamp(to.getTime()));
            return q.getResultList();
        } finally {
            em.close();
        }
    }
}