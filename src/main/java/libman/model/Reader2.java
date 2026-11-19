package libman.model;

public class Reader2 extends Member2 {
    private String readerCode;
    private String unit;
    private String readerType;
    private ReaderCard2 readerCard;

    public Reader2() {
    }

    public String getReaderCode() {
        return readerCode;
    }

    public void setReaderCode(String readerCode) {
        this.readerCode = readerCode;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getReaderType() {
        return readerType;
    }

    public void setReaderType(String readerType) {
        this.readerType = readerType;
    }

    public ReaderCard2 getReaderCard() {
        return readerCard;
    }

    public void setReaderCard(ReaderCard2 readerCard) {
        this.readerCard = readerCard;
    }
}
