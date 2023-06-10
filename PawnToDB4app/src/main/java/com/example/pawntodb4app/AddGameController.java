package com.example.pawntodb4app;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.stage.Stage;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;

public class AddGameController {

    String opening;
    ArrayList<String> white;
    ArrayList<String> black;
    String ending;

    ObservableList<String> result;
    ObservableList<String> tournaments;

    @FXML
    private Label openingLabel;

    @FXML
    private Label endingLabel;

    @FXML
    private Label recordLabel;

    @FXML
    private Button backButton;

    @FXML
    private TextField blackPlayerImie;

    @FXML
    private TextField blackPlayerNazwisko;

    @FXML
    private DatePicker dateOfMatch;

    @FXML
    private Button gameRecordButton;

    @FXML
    private ChoiceBox<String> resultChoiceBox;

    @FXML
    private Button gameAddButton;

    @FXML
    private TextField whitePlayerImie;

    @FXML
    private TextField whitePlayerNazwisko;

    @FXML
    void handleAddButton(ActionEvent event) {
        String query = "select insert_match(" +
                "?, ?, ?, ?, CAST(? AS ptdb4.match_result), ?::date, ?::int)";
        String firstNameW = whitePlayerImie.getText();
        String lastNameW = whitePlayerNazwisko.getText();
        String firstNameB = blackPlayerImie.getText();
        String lastNameB = blackPlayerNazwisko.getText();
        if (firstNameW == null || firstNameW.isEmpty()) {
            showErrorAlert("Błąd", "Imię Gracza Białego nie może być puste");
            return;
        }

        if (lastNameW == null || lastNameW.isEmpty()) {
            showErrorAlert("Błąd", "Nazwisko Gracza Białego nie może być puste");
            return;
        }
        if (firstNameB == null || firstNameB.isEmpty()) {
            showErrorAlert("Błąd", "Imię Gracza Czarnego nie może być puste");
            return;
        }

        if (lastNameB == null || lastNameB.isEmpty()) {
            showErrorAlert("Błąd", "Nazwisko Gracza Czarnego nie może być puste");
            return;
        }
        String res = resultChoiceBox.getValue();
        if (res == null) {
            showErrorAlert("Błąd", "Musisz wprowadzić wynik meczu");
            return;
        }
        LocalDate selectedDate = dateOfMatch.getValue();
        if (selectedDate == null) {
            showErrorAlert("Błąd", "Musisz wprowadzić datę meczu");
            return;
        }
        String formatted = selectedDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        //System.out.println(formatted);
        String tournament = "null";
        String id = "0";
        try {
            Connection con = DataBaseConfig.connect();
            if (con != null) {
                con.setAutoCommit(false);
            }
            try (PreparedStatement pst = con.prepareStatement(query)) {
                pst.setString(1, firstNameW);
                pst.setString(2, lastNameW);
                pst.setString(3, firstNameB);
                pst.setString(4, lastNameB);
                pst.setObject(5, res);
                pst.setString(6, formatted);
                if (tournament != "null")
                    pst.setString(7, tournament);
                else
                    pst.setNull(7, Types.INTEGER);

                ResultSet resultSet = pst.executeQuery();
                resultSet.next();
                id = resultSet.getString(1);
                System.out.println(id);
                addExtraInformation(id, con);
                con.commit();
            } catch (SQLException ex) {
                showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych przy dodawaniu partii");
                ex.printStackTrace();
                return;
            }
            showSuccessAlert("Pomyslnie dodano", "Pomyślnie dodano partie do bazy danych");
        } catch (SQLException e) {

        }
    }

    void addExtraInformation(String id, Connection con) throws SQLException {
        String queryRecord = "select insert_record(?::int, ?, ?);";

        if (opening == null || opening.isEmpty()) {
            opening = "null";
            if (ending == null || ending.isEmpty()) {
                ending = "null";
                if (white.size() == 0) return;
            }
        }
        PreparedStatement pst = con.prepareStatement(queryRecord);
        pst.setString(1, id);
        pst.setString(2, opening);
        pst.setString(3, ending);
        ResultSet res = pst.executeQuery();
        res.next();
        String recordId = res.getString(1);

        String movesQuery = "insert into PTDB4.moves_record values ( ?::int, ?::int, ?, ?);";

        for (int i = 0; i < white.size(); i++) {
            PreparedStatement pst2 = con.prepareStatement(movesQuery);
            pst2.setString(1, recordId);
            pst2.setInt(2, (i + 1));
            pst2.setString(3, white.get(i));
            pst2.setString(4, black.get(i));
            pst2.executeUpdate();
        }
    }

    @FXML
    void handleBackButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("mainMenu.fxml"));
        Parent root = loader.load();
        Stage stage = (Stage) backButton.getScene().getWindow();
        stage.setScene(new Scene(root, 320, 240));
    }

    @FXML
    void handleGameRecordButton(ActionEvent event) throws IOException {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("addExtraToGame.fxml"));
        Parent root = loader.load();

        AddExtraToGameController controller = loader.getController();
        controller.setRootController(this);

        Stage stage = new Stage();
        stage.setTitle("Szczegóły gry");
        stage.setScene(new Scene(root, 400, 300));
        stage.show();
    }

    public void initialize() {
        black = new ArrayList<>();
        white = new ArrayList<>();
        result = FXCollections.observableArrayList();
        tournaments = FXCollections.observableArrayList();
        try (Connection con = DataBaseConfig.connect()) {
            String query = "SELECT unnest(enum_range(NULL::PTDB4.match_result))";
            try (Statement statement = con.createStatement();
                 ResultSet resultSet = statement.executeQuery(query)) {
                while (resultSet.next()) {
                    String item = resultSet.getString("unnest");
                    result.add(item);
                }
            }

        } catch (SQLException ex) {
            showErrorAlert("Błąd", "Nie można nawiązać połączenia z bazą danych");
            ex.printStackTrace();
        }
        resultChoiceBox.setItems(result);
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

    public void setMoves(ArrayList<String> white, ArrayList<String> black) {
        this.white = white;
        this.black = black;

        recordLabel.setText("1. " + this.white.get(0) + " " + this.black.get(0) + "...");
    }

    public void setEnding(String ending) {
        this.ending = ending;
        endingLabel.setText(ending);
    }

    public void setOpeningName(String opening) {
        this.opening = opening;
        openingLabel.setText(opening);
    }
}