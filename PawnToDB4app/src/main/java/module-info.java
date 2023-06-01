module com.example.pawntodb4app {
    requires javafx.controls;
    requires javafx.fxml;

    requires org.controlsfx.controls;
    requires org.kordamp.bootstrapfx.core;
    requires java.sql;

    opens com.example.pawntodb4app to javafx.fxml;
    exports com.example.pawntodb4app;
}