package PojeOdevi;
import java.sql.*;
import java.util.Scanner;

public class VeritabaniIslemleri {

    public static void main(String[] args) {
        Scanner giris = new Scanner(System.in);
        int yolcuNo;
        String isim = null;
        String soyisim = null;
        String telefon = null;
        String mail = null;
        int sehirNo;
        int yolcuID = -1;

        try
        {   /***** Bağlantı kurulumu *****/
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/HavayoluVeriTabani",
                    "postgres", "ysusf0033");
            if (conn != null)
                System.out.println("Veritabanına bağlandı!");
            else
                System.out.println("Bağlantı girişimi başarısız!");

            /*** Arama ***/
            System.out.println("Aradığınız yolcunun numarasını giriniz");
            yolcuNo = giris.nextInt();
            String sql= "SELECT \"yolcuID\", \"isim\", \"soyisim\", \"telefon\", \"mail\", \"sehirNo\"  FROM \"Yolcu\" WHERE \"yolcuID\"="+yolcuNo;

            /***** Sorgu çalıştırma *****/
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            araVeYaz(yolcuNo, yolcuID, rs);

            /*** Ekleme ***/
            System.out.println("Yeni kayıt için yolcu bilgilerini giriniz:");
            /*** yolcuID Serial ***/
            System.out.print("İsim: "); isim=giris.next();
            System.out.print("Soyisim: "); soyisim=giris.next();
            System.out.print("Telefon: "); telefon=giris.next();
            System.out.print("E-Posta: "); mail=giris.next();
            System.out.print("Şehir No: "); sehirNo= giris.nextInt();
            sql= "INSERT INTO  \"Yolcu\" (\"isim\",\"soyisim\",\"telefon\",\"mail\",\"sehirNo\") VALUES(\'"+isim+"\',\'"+soyisim+"\',\'"+telefon+"\',\'"+mail+"\',\'"+sehirNo+"\')";
            stmt.executeUpdate(sql);

            /*** Güncelleme ***/
            System.out.print("Değiştirmek istediğiniz yolcunun numarasını giriniz: ");
            yolcuNo=giris.nextInt();
            sql= "SELECT \"yolcuID\", \"isim\", \"soyisim\", \"telefon\", \"mail\", \"sehirNo\"  FROM \"Yolcu\" WHERE \"yolcuID\"="+yolcuNo;
            rs = stmt.executeQuery(sql);
            araVeYaz(yolcuNo, yolcuID, rs);
            System.out.println("Yolcunun yeni bilgilerini giriniz: ");
            System.out.print("İsim: "); isim=giris.next();
            System.out.print("Soyisim: "); soyisim=giris.next();
            System.out.print("Telefon: "); telefon=giris.next();
            System.out.print("E-Posta: "); mail=giris.next();
            System.out.print("Şehir No: "); sehirNo= giris.nextInt();
            sql= "UPDATE \"Yolcu\" SET \"isim\"=\'"+isim+"\', \"soyisim\"=\'"+soyisim+"\',\"telefon\"=\'"+telefon+"\', \"mail\"=\'"+mail+"\', \"sehirNo\"=\'"+sehirNo+"\' WHERE \"yolcuID\"="+yolcuNo;
            stmt.executeUpdate(sql);

            /*** Silme ***/
            System.out.print("Silmek istediğiniz yolcunun numarasını giriniz: ");
            yolcuNo=giris.nextInt();
            sql= "DELETE FROM \"Yolcu\" WHERE \"yolcuID\"="+yolcuNo;
            stmt.executeUpdate(sql);

            System.out.println("Yolcu Silindi");

            conn.close();
            rs.close();
            stmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void araVeYaz(int yolcuNo, int yolcuID, ResultSet rs) throws SQLException {
        String soyisim;
        String telefon;
        String isim;
        String mail;
        int sehirNo;
        while(rs.next())
        {
            /***** Kayda ait alan değerlerini değişkene ata *****/
            yolcuID = rs.getInt("yolcuID");
            isim  = rs.getString("isim");
            soyisim = rs.getString("soyisim");
            telefon  = rs.getString("telefon");
            mail = rs.getString("mail");
            sehirNo = rs.getInt("sehirNo");

            /***** Ekrana yazdır *****/
            System.out.print("İsim:"+ isim);
            System.out.print(", Soyisim:" + soyisim);
            System.out.print(", Telefon:"+ telefon);
            System.out.print(", E-Posta:" + mail);
            System.out.println(", Şehir No:" + sehirNo);

        }
        if(yolcuNo != yolcuID){
            System.out.println("Aradığınız yolcu bulunamadı");
        }
    }
}
