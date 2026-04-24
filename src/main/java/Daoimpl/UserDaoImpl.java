package Daoimpl;

import java.util.List;

import Dao.UserDao;
import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import util.JpaUtil;

public class UserDaoImpl implements UserDao {

    @Override
    public void insert(User user) {

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {

            transaction.begin();
            em.persist(user);
            transaction.commit();

        } catch (Exception e) {

            transaction.rollback();
            e.printStackTrace();

        } finally {

            em.close();
        }
    }

    @Override
    public void update(User user) {

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {

            transaction.begin();
            em.merge(user);
            transaction.commit();

        } catch (Exception e) {

            transaction.rollback();
            e.printStackTrace();

        } finally {

            em.close();
        }
    }

    @Override
    public void delete(String username) {

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {

            transaction.begin();

            User user = em.find(User.class, username);

            if (user != null) {

                user.setDeleted(true);
                em.merge(user);
            }

            transaction.commit();

        } catch (Exception e) {

            transaction.rollback();
            e.printStackTrace();

        } finally {

            em.close();
        }
    }

    @Override
    public User findByUsername(String username) {

        EntityManager em = JpaUtil.getEntityManager();

        try {

            TypedQuery<User> query = em.createQuery(
                    "SELECT u FROM User u WHERE u.username = :username AND u.isDeleted = false",
                    User.class
            );

            query.setParameter("username", username);

            return query.getSingleResult();

        } catch (Exception e) {

            return null;

        } finally {

            em.close();
        }
    }

    @Override
    public List<User> findAll() {

        EntityManager em = JpaUtil.getEntityManager();

        try {

            TypedQuery<User> query = em.createQuery(
                    "SELECT u FROM User u WHERE u.isDeleted = false",
                    User.class
            );

            return query.getResultList();

        } finally {

            em.close();
        }
    }

    @Override
    public long countStaff() {

        EntityManager em = JpaUtil.getEntityManager();

        try {

            return (long) em.createQuery(
                    "SELECT COUNT(u) FROM User u WHERE u.role = false AND u.isDeleted = false"
            ).getSingleResult();

        } catch (Exception e) {

            return 0;

        } finally {

            em.close();
        }
    }

    @Override
    public User findByEmail(String email) {

        EntityManager em = JpaUtil.getEntityManager();

        try {

            TypedQuery<User> query = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email AND u.isDeleted = false",
                    User.class
            );

            query.setParameter("email", email);

            return query.getSingleResult();

        } catch (Exception e) {

            return null;

        } finally {

            em.close();
        }
    }

    @Override
    public List<User> findAllByEmail(String email) {

        EntityManager em = JpaUtil.getEntityManager();

        try {

            TypedQuery<User> query = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email AND u.isDeleted = false",
                    User.class
            );

            query.setParameter("email", email);

            return query.getResultList();

        } finally {

            em.close();
        }
    }

    @Override
    public void updatePassword(String username, String password) {

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {

            transaction.begin();

            User user = em.find(User.class, username);

            if (user != null) {

                user.setPassword(password);
                em.merge(user);
            }

            transaction.commit();

        } catch (Exception e) {

            transaction.rollback();
            e.printStackTrace();

        } finally {

            em.close();
        }
    }
}