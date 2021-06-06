package com.example.demo.vo;

import org.apache.commons.lang3.builder.ReflectionToStringBuilder;

public class EmployeeVO {

  private int id;
  private String name;


  public EmployeeVO() {

  }

  public EmployeeVO(final int id, final String name) {
    this.id = id;
    this.name = name;
  }

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }


  public String toString() {
    return ReflectionToStringBuilder.toString(this);
  }
}
