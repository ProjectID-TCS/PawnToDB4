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
    private Button addGameButton;

    @FXML
    private Button addPlayerButton;

    @FXML
    private Button searchPlayerButton;

    @FXML
    private Button addExtraToGameButton;

    @FXML
    private Button searchGameButton;

    @FXML
    void handleAddGameButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("addGame.fxml"));
        Parent root = loader.load();
        Stage stage = (Stage) addGameButton.getScene().getWindow();
        stage.setScene(new Scene(root, 600, 500));
    }
    @FXML
    void handleAddTournamentButton(ActionEvent event) throws IOException{
        FXMLLoader loader = new FXMLLoader(getClass().getResource("addTournament.fxml"));
        System.out.println("there");
        Parent root = loader.load();
        Stage stage = (Stage) addGameButton.getScene().getWindow();
        stage.setScene(new Scene(root, 600, 600));
    }

    @FXML
    public void handleAddPlayerButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("addPlayer.fxml"));
        Parent root = loader.load();
        Stage stage = (Stage) addPlayerButton.getScene().getWindow();
        stage.setScene(new Scene(root, 350, 350));
    }

    @FXML
    public void handleSearchPlayerButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("searchPlayer.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) searchPlayerButton.getScene().getWindow();
        stage.setScene(new Scene(root, 300, 300));
    }

    public void handleSearchGameButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("searchGame.fxml"));
        Parent root = loader.load();
        Stage stage = (Stage) searchGameButton.getScene().getWindow();
        stage.setScene(new Scene(root, 600, 350));
    }
}
