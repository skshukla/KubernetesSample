package com.example.demo.controller;

import com.example.demo.entity.Employee;
import com.example.demo.service.MyService;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
public class MyController {

  @Autowired
  private MyService myService;

  @GetMapping
  public String base(final HttpServletRequest request) {
    return "http://localhost:8080/1";
  }

  @GetMapping
  @RequestMapping(value = "/{id}")
  public Employee getEmployee(@PathVariable final Long id) {
    final Employee employee = this.myService.findById(id);
    return employee;
  }

  @GetMapping
  @RequestMapping(value = "/all")
  public List<Employee> getAllEmployees() {
    return this.myService.findAll();
  }

  @GetMapping
  @RequestMapping(value = "/ip")
  public String getIP() {
    return this.getIPAddress();
  }


  @PostMapping
  public void save(@RequestBody Employee employee) {
    this.myService.save(employee);
  }

  @PostMapping
  @RequestMapping(value = "/{id}/name/{newName}")
  public void updateName(@PathVariable final Long id, @PathVariable final String newName) {
    this.myService.updateNameForId(id, newName);
  }


  private String getIPAddress() {
    try {
      final String ipAddress = java.net.Inet4Address.getLocalHost().getHostAddress();
      System.out.println(String.format("Ip address of machine is {%s}", ipAddress));
      return ipAddress;
    } catch (final Exception ex) {
      ex.printStackTrace();
    }

    return "localhost";

  }
}
