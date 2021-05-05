class ProductInfo {
  ProductInfo({
    this.success,
    this.barcode,
    this.title,
    this.alias,
    this.description,
    this.brand,
    this.manufacturer,
    this.mpn,
    this.msrp,
    this.asin,
    this.category,
  });

  bool success;
  String barcode;
  String title;
  String alias;
  String description;
  String brand;
  String manufacturer;
  String mpn;
  String msrp;
  String asin;
  String category;

  // creates an object of ProductInfo whenever it is called. 
  factory ProductInfo.fromJson(Map<String, dynamic> json) => ProductInfo(
        success: json["success"],
        barcode: json["barcode"],
        title: json["title"],
        alias: json["alias"],
        description: json["description"],
        brand: json["brand"],
        manufacturer: json["manufacturer"],
        mpn: json["mpn"],
        msrp: json["msrp"],
        asin: json["ASIN"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "barcode": barcode,
        "title": title,
        "alias": alias,
        "description": description,
        "brand": brand,
        "manufacturer": manufacturer,
        "mpn": mpn,
        "msrp": msrp,
        "ASIN": asin,
        "category": category,
      };
}
