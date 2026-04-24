package Dao;

import java.util.List;
import entity.Drink;

public interface DrinkDao {
    void insert(Drink drink);
    void update(Drink drink);
    void delete(int drinkId);
    Drink findById(int drinkId);
    List<Drink> findAll();
    List<Drink> findByCategory(String category);
    long countAll();
    List<Drink> findByPage(String keyword, int offset, int limit);
    long countByKeyword(String keyword);
}
