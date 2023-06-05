package com.example.pawntodb4app;

import java.sql.Connection;
import java.sql.DriverManager;

public class DataBaseConfig {
    private static final String URL = "jdbc:postgresql://localhost:5432/postgres";
    private static final String USER = "postgres";
    private static final String PASSWORD = "postgres";

    public static Connection connect() {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            System.out.println("Nie udało sie połaczyc z baza.");
            e.printStackTrace();
        }
        return null;
    }
}
