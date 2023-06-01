package com.example.pawntodb4app;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.stage.Stage;

import java.io.IOException;

public class MainMenuController {
    @FXML
    private Button addPlayerButton;

    @FXML
    private Button searchPlayerButton;

    @FXML
    public void handleAddPlayerButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("addPlayer.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) addPlayerButton.getScene().getWindow();
        stage.setScene(new Scene(root, 800, 600));
    }

    @FXML
    public void handleSearchPlayerButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("searchPlayer.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) searchPlayerButton.getScene().getWindow();
        stage.setScene(new Scene(root, 800, 600));
    }
}
