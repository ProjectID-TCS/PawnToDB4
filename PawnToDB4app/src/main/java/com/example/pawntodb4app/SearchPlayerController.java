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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
    public void handleSearchButton() throws IOException {
        String firstName = firstNameField.getText();
        String lastName = lastNameField.getText();

        if (firstName == null || firstName.isEmpty()) {
            showAlert("Błąd", "Imię nie może być puste");
            return;
        }

        if (lastName == null || lastName.isEmpty()) {
            showAlert("Błąd", "Nazwisko nie może być puste");
            return;
        }

        Player player = searchPlayer(firstName, lastName);
        if (player == null) {
            showAlert("Nie znaleziono", "Nie znaleziono gracza o podanym imieniu i nazwisku");
        } else {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("playerDetails.fxml"));
            Parent root = loader.load();

            PlayerDetailsController controller = loader.getController();
            controller.setPlayer(player);
            controller.loadChartData(player.getId());

            Stage stage = new Stage();
            stage.setTitle("Szczegóły Gracza");
            stage.setScene(new Scene(root, 1000, 800));
            stage.show();
        }
    }

    private Player searchPlayer(String firstName, String lastName) {
        String query = "SELECT p.id, p.first_name, p.last_name, g.group_name " +
                "FROM PTDB4.players p " +
                "JOIN PTDB4.groups g ON p.group_id = g.id " +
                "WHERE p.first_name = ? AND p.last_name = ?";
        try (Connection con = DataBaseConfig.connect();
             PreparedStatement pst = con.prepareStatement(query)) {

            pst.setString(1, firstName);
            pst.setString(2, lastName);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return new Player(rs.getInt("id"),
                            rs.getString("first_name"),
                            rs.getString("last_name"), rs.getString("group_name"));
                }
            }

        } catch (SQLException ex) {
            showAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        return null;
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
