package friendaoke;

public class VideoInfoBean {
    private String name;
    private String artist;
    private String albumURL;

    public VideoInfoBean(String name, String artist, String albumURL) {
        this.name = name;
        this.artist = artist;
        this.albumURL = albumURL;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getAlbumURL() {
        return albumURL;
    }

    public void setAlbumURL(String albumURL) {
        this.albumURL = albumURL;
    }
}
