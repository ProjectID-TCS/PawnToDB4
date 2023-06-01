package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
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
        int elo = Integer.parseInt(eloField.getText());
        addPlayer(firstName, lastName, elo);
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
}
