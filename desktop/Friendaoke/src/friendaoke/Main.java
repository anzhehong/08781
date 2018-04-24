package friendaoke;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class Main extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception{
        FXMLLoader loader = new FXMLLoader(getClass().getResource("sample.fxml"));
        Parent root = loader.load();
        root.setStyle("-fx-background-image: url('https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQxsasGQIwQNwjek3F1nSwlfx60g6XpOggnxw5dyQrtCL_0x8IW')");

        primaryStage.setTitle("Friendaoke Desktop");
        primaryStage.setScene(new Scene(root));
        primaryStage.show();

        primaryStage.setOnCloseRequest(event -> {
            ((Controller) loader.getController()).dispose();
        });
    }

    public static void main(String[] args) {
        launch(args);
    }
}
