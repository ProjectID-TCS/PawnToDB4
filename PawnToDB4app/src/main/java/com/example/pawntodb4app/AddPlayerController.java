package com.example.pawntodb4app;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.stage.Stage;

import java.io.IOException;
import java.sql.*;

public class AddPlayerController {
    ObservableList<String> options;
    @FXML
    private TextField firstNameField;

    @FXML
    private TextField lastNameField;

    @FXML
    private TextField eloField;

    @FXML
    private ComboBox<String> groupChoiceBox;
    @FXML
    private Button addButton;

    @FXML
    private Button backButton;

    @FXML
    public void handleAddButton() {
        String firstName = firstNameField.getText();
        String lastName = lastNameField.getText();
        String eloString = eloField.getText();
        if (firstName == null || firstName.isEmpty()) {
            showAlert("Błąd", "Imię nie może być puste");
            return;
        }

        if (lastName == null || lastName.isEmpty()) {
            showAlert("Błąd", "Nazwisko nie może być puste");
            return;
        }

        if (eloString == null || eloString.isEmpty()) {
            showAlert("Błąd", "ELO nie może być puste");
            return;
        }

        int elo;
        try {
            elo = Integer.parseInt(eloString);
        } catch (NumberFormatException e) {
            showAlert("Błąd", "ELO musi być liczbą całkowitą");
        }

    }

    private void addPlayer(String firstName, String lastName, int elo) {
        //TODO add player do db
    }
    public void initialize() {
        options = FXCollections.observableArrayList();
        try (Connection con = DataBaseConfig.connect()){
            String query = "SELECT group_name FROM PTDB4.GROUPS";
            try(Statement statement = con.createStatement();
                ResultSet resultSet = statement.executeQuery(query)){
                while(resultSet.next()){
                    String item = resultSet.getString("group_name");
                    System.out.println("siema "+ item);
                    options.add(item);
                }
            }

        } catch (SQLException ex) {
            showAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        groupChoiceBox.getItems().addAll(options);
        System.out.println(groupChoiceBox.getItems().size());
    }
    @FXML
    public void handleBackButton() throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 320, 240));
    }

    private void showAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
