package com.example.pawntodb4app;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.Alert;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TextArea;
import javafx.stage.Stage;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AddExtraToGameController {

    AddGameController rootController;

    @FXML
    private ComboBox<String> openingBox;

    @FXML
    private ComboBox<String> endingBox;

    @FXML
    private TextArea movesRecordArea;

    @FXML
    public void initialize() {
        loadOpenings();
    }

    private void loadOpenings() {
        ObservableList<String> options = FXCollections.observableArrayList();
        ObservableList<String> optionsEnd = FXCollections.observableArrayList();
        try {
            Connection connection = DataBaseConfig.connect();
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT name FROM PTDB4.openings");
            while (resultSet.next()) {
                String item = resultSet.getString("name");
                options.add(item);
            }
            openingBox.setItems(options);

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        optionsEnd.add("resignation");
        optionsEnd.add("mate");
        optionsEnd.add("time");
        optionsEnd.add("agreement");
        endingBox.setItems(optionsEnd);
    }

    @FXML
    public void handleAddButton() {
        String record = movesRecordArea.getText();
        if (!Objects.equals(record, "")) {
            record += " ";
            String regex = "(\\d+\\.\\s\\b\\w{1,7}\\b\\s\\b\\w{1,7}\\b\\s)*";
            Pattern pattern = Pattern.compile(regex);
            Matcher matcher = pattern.matcher(record);
            if (!matcher.matches()) {
                showErrorAlert("Błąd", "Niepoprawny format parti");
                return;
            }

            ArrayList<String> white = new ArrayList<>();
            ArrayList<String> black = new ArrayList<>();

            String[] splitStrings = record.split("\\d+\\.\\s");
            for (String s : splitStrings) {
                String[] words = s.split("\\s");
                if (words.length >= 2) {
                    white.add(words[0]);
                    black.add(words[1]);
                }
            }
            rootController.setMoves(white, black);
        }
        String ending = endingBox.getValue();
        if (ending == null || ending.isEmpty()) {
            showErrorAlert("Błąd", "Ending nie może byc pusty");
            return;
        }
        rootController.setEnding(endingBox.getValue());
        rootController.setOpeningName(openingBox.getValue());
        showSuccessAlert("Pomyslnie dodano", "Pomyślnie dodano dodatkowe szczegóły gry");
        Stage stage = (Stage) openingBox.getScene().getWindow();
        stage.close();
    }

    private void showErrorAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }

    private void showSuccessAlert(String title, String message) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }

    public void setRootController(AddGameController rootController) {
        this.rootController = rootController;
    }
}