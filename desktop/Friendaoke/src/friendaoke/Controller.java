package friendaoke;

import friendaoke.services.CommandService;
import friendaoke.services.VoiceStreamService;
import javafx.beans.Observable;
import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.concurrent.Service;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;
import javafx.scene.media.Media;
import javafx.scene.media.MediaPlayer;
import javafx.scene.media.MediaView;

import java.io.File;

public class Controller {

    @FXML
    public MediaView mediaView;

    @FXML
    public Button playButton;
    public ListView<MediaPlayerItem> videoList;

    private MediaPlayer mediaPlayer = null;
    private StringProperty property = null;
    private Service voiceStreamService = null;
    private Service commandService = null;

    @FXML
    public void initialize() {
        videoList.setItems(getMediaItems());
        videoList.getSelectionModel().selectedItemProperty().addListener((observable, oldValue, newValue) -> {
            mediaView.setMediaPlayer(observable.getValue().mediaPlayer);
            mediaPlayer = observable.getValue().mediaPlayer;
        });
        videoList.getSelectionModel().selectFirst();

        property = new SimpleStringProperty();
        property.addListener((observable, oldValue, newValue) -> {
            System.out.println("oldValue: " + oldValue);
            System.out.println("newValue: " + newValue);
//            controlMedia();
        });

        voiceStreamService = new VoiceStreamService();
        voiceStreamService.start();

        commandService = new CommandService();
        commandService.start();

        property.bind(commandService.messageProperty());

    }

    public void onPlayButtonClick(ActionEvent actionEvent) {
        controlMedia();
    }

    private void controlMedia() {
        if (mediaPlayer.getStatus().equals(MediaPlayer.Status.PLAYING)) {
            mediaPlayer.pause();
        } else {
            mediaPlayer.play();
        }
    }

    public void dispose() {
        for (MediaPlayerItem item : videoList.getItems()) {
            item.mediaPlayer.dispose();
        }
        voiceStreamService.cancel();
        commandService.cancel();
    }

    public ObservableList<MediaPlayerItem> getMediaItems() {
        ObservableList<MediaPlayerItem> mediaItems = FXCollections.observableArrayList(
                i -> new Observable[]{i.mediaName});
        mediaItems.add(new MediaPlayerItem("test1.mp4"));
        mediaItems.add(new MediaPlayerItem("test2.mp4"));
        mediaItems.add(new MediaPlayerItem("test3.mp4"));
        mediaItems.add(new MediaPlayerItem("test4.mp4"));
        return mediaItems;
    }

    private class MediaPlayerItem {
        MediaPlayer mediaPlayer = null;
        StringProperty mediaName = new SimpleStringProperty();
        String videoFolder = "video";
        MediaPlayerItem(String mediaName) {
            this.mediaName.set(mediaName);
            mediaPlayer = new MediaPlayer(new Media(getClass().getResource(videoFolder + File.separator + mediaName).toExternalForm()));
        }

        @Override
        public String toString() {
            return mediaName.get();
        }
    }
}
