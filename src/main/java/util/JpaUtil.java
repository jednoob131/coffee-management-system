package util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class JpaUtil {
    private static EntityManagerFactory factory;

    private static void init() {
        try {
            if (factory == null) {
                factory = Persistence.createEntityManagerFactory("PollyCoffee");
                System.out.println(">>> EntityManagerFactory created OK");
            }
        } catch (Exception e) {
            System.err.println(">>> LỖI TẠO ENTITY MANAGER FACTORY");
            e.printStackTrace();
            throw new RuntimeException("Không tạo được EntityManagerFactory", e);
        }
    }

    public static EntityManager getEntityManager() {
        if (factory == null) init();
        return factory.createEntityManager();
    }
}
