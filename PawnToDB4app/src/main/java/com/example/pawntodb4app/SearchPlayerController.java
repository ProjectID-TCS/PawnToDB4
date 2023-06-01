package com.example.pawntodb4app;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;

public class SearchPlayerController {
    @FXML
    private TextField firstNameField;

    @FXML
    private TextField lastNameField;

    @FXML
    private Button searchButton;

    @FXML
    private Button backButton;

    @FXML
    public void handleSearchButton() {
        String firstName = firstNameField.getText();
        String lastName = lastNameField.getText();

        //Player player = searchPlayer(firstName, lastName);//TODO make Player class
        System.out.println(firstName + " " + lastName);
    }

    private void searchPlayer(String firstName, String lastName) {
        //TODO search for player in db
    }

    @FXML
    public void handleBackButton() throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 800, 600));
    }
}
