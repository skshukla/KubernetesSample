package com.example.demo.util;

public class SortUtil {

  public static void mergeSort(Integer[] arr) {

    mergeSort_Sort(arr, 0, arr.length - 1);
  }

  private static void mergeSort_Sort(Integer[] arr, int s, int e) {
    if (e <= s) {
      return;
    }
    if (e == s + 1) {

      if (arr[e] < arr[s]) {
        swap(arr, s, e);
      }
      return;
    }
    int m = s + (e - s) / 2;
    mergeSort_Sort(arr, s, m);
    mergeSort_Sort(arr, m + 1, e);
    mergeSort_Merge(arr, s, m + 1, e);
  }

  private static void mergeSort_Merge(Integer[] arr, int s, int k, int e) {
    for (int counter = k; counter <= e; counter++) {
      int p = counter;
      while (p > s && arr[p] < arr[p - 1]) {
        swap(arr, p, p - 1);
        p = p - 1;
      }
    }
  }

  private static void swap(Integer[] arr, int k, int l) {
    int tmp = arr[k];
    arr[k] = arr[l];
    arr[l] = tmp;
  }
}
