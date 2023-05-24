package org.example;
import java.sql.*;

public class Main {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/postgres";
        String username = "postgres";
        String password = "postgres";

        try {
            // Nawiązanie połączenia z bazą danych
            Connection connection = DriverManager.getConnection(url, username, password);

            // Sprawdzenie istnienia tabeli
            String tableName = "a";
            boolean tableExists = false;
            DatabaseMetaData metaData = connection.getMetaData();
            ResultSet tables = metaData.getTables(null, null, tableName, null);
            if (tables.next()) {
                tableExists = true;
            }
            tables.close();

            // Dodanie tabeli, jeśli nie istnieje
            if (!tableExists) {
                String createTableQuery = "CREATE TABLE A (number INTEGER)";
                Statement statement = connection.createStatement();
                statement.executeUpdate(createTableQuery);
                System.out.println("Tabela utworzona pomyślnie.");
                statement.close();
            } else {
                System.out.println("Tabela już istnieje.");
            }

            // Dodanie krotki do tabeli
            String insertQuery = "INSERT INTO A (number) VALUES (1)";
            Statement statement = connection.createStatement();
            statement.executeUpdate(insertQuery);
            System.out.println("Krotka dodana pomyślnie.");

            // Wypisanie zawartości tabeli
            String selectQuery = "SELECT * FROM A";
            ResultSet resultSet = statement.executeQuery(selectQuery);
            System.out.println("Zawartość tabeli A:");
            while (resultSet.next()) {
                int number = resultSet.getInt("number");
                System.out.println("Number: " + number);
            }

            // Zamknięcie połączenia
            resultSet.close();
            statement.close();
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
