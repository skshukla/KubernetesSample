package com.example.demo.service;

import com.example.demo.entity.Employee;
import com.example.demo.repository.MyRepository;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MyService {

  @Autowired
  private MyRepository myRepository;


  public Employee save(final Employee employee) {
    return this.myRepository.save(employee);
  }

  public List<Employee> findAll() {
    List<Employee> employeeList = new ArrayList<>();
    this.myRepository.findAll().forEach(employeeList::add);
    return employeeList;
  }

  public Employee findById(final long id) {
    return this.myRepository.findById(id);
  }

  public List<Employee> findByName(final String name) {
    return this.myRepository.findByName(name);
  }

  public void updateNameForId(final long id, final String name) {
    final Employee employee = this.myRepository.findById(id);
    employee.setName(name);
    this.myRepository.save(employee);
  }

}
