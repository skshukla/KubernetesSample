package com.example.demo.repository;


import com.example.demo.entity.Employee;
import java.util.List;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MyRepository extends CrudRepository<Employee, Long> {

  List<Employee> findByName(final String name);

  Employee findById(long id);
}