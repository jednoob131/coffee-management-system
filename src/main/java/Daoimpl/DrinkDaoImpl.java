package Daoimpl;

import java.util.List;
import Dao.DrinkDao;
import entity.Drink;
import jakarta.persistence.*;
import util.JpaUtil;

public class DrinkDaoImpl implements DrinkDao {

    @Override
    public void insert(Drink drink) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try { t.begin(); em.persist(drink); t.commit(); }
        catch (Exception e) { t.rollback(); }
        finally { em.close(); }
    }

    @Override
    public void update(Drink drink) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try { t.begin(); em.merge(drink); t.commit(); }
        catch (Exception e) { t.rollback(); }
        finally { em.close(); }
    }

    @Override
    public void delete(int drinkId) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction t = em.getTransaction();
        try {
            t.begin();
            Drink d = em.find(Drink.class, drinkId);
            if (d != null) em.remove(d);
            t.commit();
        } catch (Exception e) { t.rollback(); }
        finally { em.close(); }
    }

    @Override
    public Drink findById(int drinkId) {
        EntityManager em = JpaUtil.getEntityManager();
        try { return em.find(Drink.class, drinkId); }
        catch (Exception e) { return null; }
        finally { em.close(); }
    }

    @Override
    public List<Drink> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT d FROM Drink d", Drink.class).getResultList();
        } finally { em.close(); }
    }

    @Override
    public List<Drink> findByCategory(String category) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Drink> q = em.createQuery(
                "SELECT d FROM Drink d WHERE d.category = :cat", Drink.class);
            q.setParameter("cat", category);
            return q.getResultList();
        } finally { em.close(); }
    }

    @Override
    public long countAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return (long) em.createQuery("SELECT COUNT(d) FROM Drink d").getSingleResult();
        } catch (Exception e) { return 0; }
        finally { em.close(); }
    }
    @Override
    public List<Drink> findByPage(String keyword, int offset, int limit) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            // Tìm kiếm theo tên hoặc danh mục, ưu tiên các món mới lên đầu
            TypedQuery<Drink> query = em.createQuery(
                    "SELECT d FROM Drink d WHERE (d.drinkName LIKE :kw OR d.category LIKE :kw) ORDER BY d.drinkId DESC",
                    Drink.class);
            query.setParameter("kw", "%" + keyword + "%");
            query.setFirstResult(offset);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countByKeyword(String keyword) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                    "SELECT COUNT(d) FROM Drink d WHERE (d.drinkName LIKE :kw OR d.category LIKE :kw)",
                    Long.class);
            query.setParameter("kw", "%" + keyword + "%");
            return query.getSingleResult();
        } catch (Exception e) {
            return 0;
        } finally {
            em.close();
        }
    }
}
