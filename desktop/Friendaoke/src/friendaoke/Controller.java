package friendaoke;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import friendaoke.services.CommandService;
import friendaoke.services.VoiceStreamService;
import javafx.application.Platform;
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
import javafx.scene.control.Slider;
import javafx.scene.media.Media;
import javafx.scene.media.MediaPlayer;
import javafx.scene.media.MediaView;
import javafx.util.Duration;

import java.io.File;
import java.util.List;
import java.util.StringTokenizer;

public class Controller {

    private final static String PLAY = "PLAY";
    private final static String PAUSE = "PAUS";
    private final static String NEXT = "NEXT";
    private final static String PREVIOUS = "PREV";
    private final static String VOLUME_UP = "VOLUME_UP";
    private final static String VOLUME_DOWN = "VOLUME_DOWN";

    private final static String SELECT = "SELECT";
    private final static String DELIM = "@";

    public final static String VIDEO_LIST_REQUEST = "VIDEO_LIST_REQUEST";

    @FXML
    public MediaView mediaView;

    @FXML
    public Button playButton;
    public ListView<MediaPlayerItem> videoList;
    public Slider timeSlider;
    public Slider volumeSlider;

    private MediaPlayerItem selectedMediaPlayerItem = null;
    private StringProperty property = null;
    private Service voiceStreamService = null;
    private Service commandService = null;

    private List<VideoInfoBean> videoInfoList;

    @FXML
    public void initialize() {

        videoInfoList = getVideoInfoList();

        videoList.setItems(getMediaItems());
        videoList.getSelectionModel().selectedItemProperty().addListener((observable, oldValue, newValue) -> {
            mediaView.setMediaPlayer(observable.getValue().mediaPlayer);
            selectedMediaPlayerItem = observable.getValue();
            selectedMediaPlayerItem.updateValues();
        });
        videoList.getSelectionModel().selectFirst();

        timeSlider.valueProperty().addListener(ov -> {
            if (timeSlider.isValueChanging()) {
                // multiply duration by percentage calculated by slider position
                selectedMediaPlayerItem.mediaPlayer.seek(
                        selectedMediaPlayerItem.duration.multiply(timeSlider.getValue() / 100.0));
            }
        });

        volumeSlider.valueProperty().addListener(ov -> {
            if (volumeSlider.isValueChanging()) {
                selectedMediaPlayerItem.mediaPlayer.setVolume(volumeSlider.getValue() / 100.0);
            }
        });

        property = new SimpleStringProperty();
        property.addListener((observable, oldValue, newValue) -> {
            System.out.println("oldValue: " + oldValue);
            System.out.println("newValue: " + newValue);
            processCommand(newValue);
        });

        voiceStreamService = new VoiceStreamService();
        voiceStreamService.start();

        commandService = new CommandService(videoInfoList);
        commandService.start();

        property.bind(commandService.messageProperty());

    }

    private void processCommand(String command) {
        switch (command) {
            case PLAY:
            case PAUSE:
                controlMedia();
                break;
            case VOLUME_UP:
                setVolumeUp();
                break;
            case VOLUME_DOWN:
                setVolumeDown();
                break;
            case PREVIOUS:
                prevMedia();
                break;
            case NEXT:
                nextMedia();
                break;
            default:
                selectMedia(command);
                break;
        }
    }

    private void setVolumeUp() {
        volumeSlider.increment();
    }

    private void setVolumeDown() {
        volumeSlider.decrement();
    }

    private void nextMedia() {
        int selected = videoList.getSelectionModel().getSelectedIndex();
        int next = (selected+1) % videoList.getItems().size();
        videoList.getSelectionModel().selectIndices(next);
    }

    private void prevMedia() {
        int selected = videoList.getSelectionModel().getSelectedIndex();
        int prev = (selected+videoList.getItems().size()-1) % videoList.getItems().size();
        videoList.getSelectionModel().selectIndices(prev);
    }

    private void selectMedia(String command) {
        StringTokenizer tokenizer = new StringTokenizer(command, DELIM);
        if (tokenizer.nextToken().equals(SELECT)) {
            String selectedVideoName = tokenizer.nextToken();
            int i = 0;
            for (; i < videoInfoList.size(); i++) {
                if (videoInfoList.get(i).getName().equals(selectedVideoName)) {
                    break;
                }
            }
            videoList.getSelectionModel().selectIndices(i);
        }
    }

    public void onPlayButtonClick(ActionEvent actionEvent) {
        controlMedia();
    }

    private void controlMedia() {
        MediaPlayer player = selectedMediaPlayerItem.mediaPlayer;
        MediaPlayer.Status status = player.getStatus();

        if (status == MediaPlayer.Status.UNKNOWN  || status == MediaPlayer.Status.HALTED)
        {
            // don't do anything in these states
            return;
        }

        if ( status == MediaPlayer.Status.PAUSED
                || status == MediaPlayer.Status.READY
                || status == MediaPlayer.Status.STOPPED)
        {
            // rewind the movie if we're sitting at the end
            if (selectedMediaPlayerItem.atEndOfMedia) {
                player.seek(player.getStartTime());
                selectedMediaPlayerItem.atEndOfMedia = false;
            }
            player.play();
            playButton.setText("PAUSE");
        } else {
            player.pause();
            playButton.setText("PLAY");
        }
    }

    List<VideoInfoBean> getVideoInfoList() {
        Gson gson = new Gson();
        List<VideoInfoBean> list =
                gson.fromJson(VIDEO_INFO, new TypeToken<List<VideoInfoBean>>(){}.getType());
        return list;
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
        for (VideoInfoBean video : videoInfoList) {
            mediaItems.add(new MediaPlayerItem(video.getName() + ".mp4"));
        }
        return mediaItems;
    }

    private class MediaPlayerItem {
        boolean atEndOfMedia = false;
        Duration duration = null;
        MediaPlayer mediaPlayer = null;
        boolean stopRequested = false;
        StringProperty mediaName = new SimpleStringProperty();
        String videoFolder = "video";
        MediaPlayerItem(String mediaName) {
            this.mediaName.set(mediaName);
            mediaPlayer = new MediaPlayer(new Media(getClass().getResource(videoFolder + File.separator + mediaName).toExternalForm()));
            mediaPlayer.currentTimeProperty().addListener(ov -> updateValues());
            mediaPlayer.setOnReady(() -> duration = mediaPlayer.getMedia().getDuration());
            mediaPlayer.setOnPlaying(() -> {
                if (stopRequested) {
                    mediaPlayer.pause();
                    stopRequested = false;
                }
            });
            mediaPlayer.setOnEndOfMedia(() -> {
                stopRequested = true;
                atEndOfMedia = true;
            });
        }

        void updateValues() {
            if (timeSlider != null && volumeSlider != null) {
                Platform.runLater(() -> {
                    Duration currentTime = mediaPlayer.getCurrentTime();
                    if (duration != null) {
                        timeSlider.setDisable(duration.isUnknown());
                        if (!timeSlider.isDisabled()
                                && duration.greaterThan(Duration.ZERO)
                                && !timeSlider.isValueChanging()) {
                            timeSlider.setValue(currentTime.divide(duration).toMillis()
                                    * 100.0);
                        }
                    }
                    if (!volumeSlider.isValueChanging()) {
                        volumeSlider.setValue((int)Math.round(mediaPlayer.getVolume()
                                * 100));
                    }
                });
            }
        }

        @Override
        public String toString() {
            return mediaName.get();
        }
    }

    private static final String VIDEO_INFO = "[\n" +
            "  {\n" +
            "    \"name\": \"Total Eclipse Of The Heart\",\n" +
            "    \"artist\": \"Bonnie Tyler\",\n" +
            "    \"albumURL\": \"https://upload.wikimedia.org/wikipedia/en/0/09/Total_Eclipse_of_the_Heart_-_single_cover.jpg\"\n" +
            "  },\n" +
            "  {\n" +
            "    \"name\": \"Look What You Made Me Do\",\n" +
            "    \"artist\": \"Taylor Swift\",\n" +
            "    \"albumURL\": \"https://upload.wikimedia.org/wikipedia/en/6/68/Taylor_Swift_-_Look_What_You_Made_Me_Do.png\"\n" +
            "  },\n" +
            "  {\n" +
            "    \"name\": \"I Got You\",\n" +
            "    \"artist\": \"Bebe Rexha\",\n" +
            "    \"albumURL\": \"https://upload.wikimedia.org/wikipedia/en/c/c9/Bebe_Rexha_-_I_Got_You.png\"\n" +
            "  },\n" +
            "  {\n" +
            "    \"name\": \"Church Bells\",\n" +
            "    \"artist\": \"Carrie Underwood\",\n" +
            "    \"albumURL\": \"https://upload.wikimedia.org/wikipedia/en/5/51/Carrie_Underwood_-_Church_Bells_%28Official_Single_Cover%29.png\"\n" +
            "  }\n" +
            "]";
}
