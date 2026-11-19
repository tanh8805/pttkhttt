package libman.model;

import java.util.Date;

public class ReturnReceipt2 {
    private int id;
    private String returnCode;
    private Date returnDate;
    private float totalFine;
    private Reader2 reader;
    private Librarian2 librarian;
    private ReturnReceiptDetail2[] details;

    public ReturnReceipt2() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    public Date getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(Date returnDate) {
        this.returnDate = returnDate;
    }

    public float getTotalFine() {
        return totalFine;
    }

    public void setTotalFine(float totalFine) {
        this.totalFine = totalFine;
    }

    public Reader2 getReader() {
        return reader;
    }

    public void setReader(Reader2 reader) {
        this.reader = reader;
    }

    public Librarian2 getLibrarian() {
        return librarian;
    }

    public void setLibrarian(Librarian2 librarian) {
        this.librarian = librarian;
    }

    public ReturnReceiptDetail2[] getDetails() {
        return details;
    }

    public void setDetails(ReturnReceiptDetail2[] details) {
        this.details = details;
    }
}
