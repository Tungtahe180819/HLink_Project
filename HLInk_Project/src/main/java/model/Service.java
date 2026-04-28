package model;

public class Service {
    private int serviceId;
    private String serviceName;
    private double basePrice;
    private double pricePerKm;

    public Service() {}

    public Service(int serviceId, String serviceName, double basePrice, double pricePerKm) {
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.basePrice = basePrice;
        this.pricePerKm = pricePerKm;
    }

    // Getter và Setter
    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }
    public double getPricePerKm() { return pricePerKm; }
    public void setPricePerKm(double pricePerKm) { this.pricePerKm = pricePerKm; }
}