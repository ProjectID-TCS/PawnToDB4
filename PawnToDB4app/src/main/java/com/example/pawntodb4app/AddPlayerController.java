package com.example.pawntodb4app;

import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.collections.transformation.FilteredList;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;
import java.sql.*;

public class AddPlayerController {
    ObservableList<String> options;
    FilteredList<String> filteredOptions;
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
        String group_name = groupChoiceBox.getValue();
        if (firstName == null || firstName.isEmpty()) {
            showErrorAlert("Błąd", "Imię Gracza nie może być puste");
            return;
        }

        if (lastName == null || lastName.isEmpty()) {
            showErrorAlert("Błąd", "Nazwisko Gracza nie może być puste");
            return;
        }

        if (eloString == null || eloString.isEmpty()) {
            showErrorAlert("Błąd", "ELO Gracza nie może być puste");
            return;
        }

        int elo = 0;
        try {
            elo = Integer.parseInt(eloString);
        } catch (NumberFormatException e) {
            showErrorAlert("Błąd", "ELO musi być liczbą całkowitą");
        }
        if (addPlayer(firstName, lastName, elo, group_name))
            showSuccessAlert("Dodano gracza", "Pomyślnie dodano gracza");
    }

    private boolean addPlayer(String firstName, String lastName, int elo, String groupName) {
        String query = "INSERT INTO PTDB4.player_insert_view (first_name, last_name, max_elo, group_name) VALUES (?, ?, ?, ?)";

        try (Connection con = DataBaseConfig.connect();
             PreparedStatement pst = con.prepareStatement(query)) {
            pst.setString(1, firstName);
            pst.setString(2, lastName);
            pst.setInt(3, elo);
            pst.setString(4, groupName);
            pst.executeUpdate();
        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
            return false;
        }
        return true;
    }


    public void initialize() {
        groupChoiceBox.setEditable(true);
        options = FXCollections.observableArrayList();
        try (Connection con = DataBaseConfig.connect()) {
            String query = "SELECT group_name FROM PTDB4.GROUPS";
            try (Statement statement = con.createStatement();
                 ResultSet resultSet = statement.executeQuery(query)) {
                while (resultSet.next()) {
                    String item = resultSet.getString("group_name");
                    options.add(item);
                }
            }

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        filteredOptions = new FilteredList<>(options, p -> true);
        System.out.println(groupChoiceBox.getItems().size());
        groupChoiceBox.getEditor().textProperty().addListener((obs,oldV,newV) -> {
            final TextField ed = groupChoiceBox.getEditor();
            final String selected = groupChoiceBox.getSelectionModel().getSelectedItem();
            Platform.runLater(() ->{
                if(selected == null || selected.equals(ed.getText())) {
                    filteredOptions.setPredicate(( item ->
                            item.toUpperCase().startsWith(newV.toUpperCase())));
                }
            });
        });
        groupChoiceBox.setItems(filteredOptions);
    }

    @FXML
    public void handleBackButton() throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();

        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 320, 240));
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
}
