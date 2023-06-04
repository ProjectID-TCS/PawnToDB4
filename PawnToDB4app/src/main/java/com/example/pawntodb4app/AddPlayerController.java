package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;

public class AddPlayerController {
    @FXML
    private TextField firstNameField;

    @FXML
    private TextField lastNameField;

    @FXML
    private TextField eloField;

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

    @FXML
    public void handleBackButton() throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 800, 600));
    }

    private void showAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
