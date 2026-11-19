package libman.model;

public class BorrowableDocument2 {
    private int id;
    private String copyCode;
    private String location;
    private String status;
    private Document2 document;

    public BorrowableDocument2() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCopyCode() {
        return copyCode;
    }

    public void setCopyCode(String copyCode) {
        this.copyCode = copyCode;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Document2 getDocument() {
        return document;
    }

    public void setDocument(Document2 document) {
        this.document = document;
    }
}
