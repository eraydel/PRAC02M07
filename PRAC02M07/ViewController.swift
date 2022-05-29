//
//  ViewController.swift
//  PRAC02M07
//
//  Created by Erick Ayala Delgadillo on 28/05/22.
//

import UIKit
import WebKit


class ViewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var nombreArchivo: UILabel!
    
    var tipo: String?
    var fileName: String = ""
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tipo
        setFileName(tipo!)

        indicator.style = .large
        indicator.color = .red
        indicator.hidesWhenStopped = true
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        
        if existeLocalmente() {
            self.mostrarArchivo()
        }
        else {
            
            // 1. comprueba conexión a internet
            if InternetStatus.instance.internetType != .none {
                descargaArchivo()
            } else {
                let alert = UIAlertController(title: "No hay inyternet", message: "Debe estar conectado para poder descargar el contenido.", preferredStyle: .alert)
                let boton = UIAlertAction(title: "Continuar",style: .default)
                alert.addAction(boton)
                self.present(alert,animated: true)
                self.indicator.stopAnimating()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(InternetStatus.instance.internetType)
    }
    
    
    // para verificar si el archivo existe en local
    func existeLocalmente() -> Bool {
        
        var exists: Bool = false
        //setting home directory
        let homeDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let rutaArchivo = URL(string: homeDirURL.path + "/" + fileName){
            if FileManager.default.fileExists(atPath: rutaArchivo.path) {
                exists = true
            } else {
                exists = false
            }
        }
        self.indicator.startAnimating()
        return exists
    }
    
    func descargaArchivo(){
        let baseURL = "http://janzelaznog.com/DDAM/iOS/vim/"
        if let url = URL(string: baseURL + fileName ) {
            var request = URLRequest(url: url )
            request.httpMethod = "GET"
            let sesion = URLSession.shared
            let task = sesion.dataTask(with: request) { data, response, error in
                if error != nil {
                    print ("ocurrio un error \(error!.localizedDescription)")
                }
                else {
                    //guardamos archivo
                    print("guardando archivo ... " + self.fileName)
                    self.guardaArchivo(data!, self.fileName)
                    DispatchQueue.main.async {
                        self.mostrarArchivo()
                        self.indicator.stopAnimating()
                    }
                }
            }
            indicator.startAnimating()
            task.resume()
        }
        else {
            print("error al consultar la ruta")
        }
    }
    
    // para setear nombre del archivo
    func setFileName(_ option: String) {
        switch tipo {
            case "Locations" : fileName = "localidades.xlsx"
            case "Articles"  : fileName = "Articles.pdf"
            case "Images"    : fileName = "geo_vertical.jpg"
            default: print("hi bro!")
        }
    }
    
    
    //guarda archivo
    func guardaArchivo(_ bytes:Data, _ nombre:String) {
        // 1. Obtenemos la ubicacion de la carpeta de documents
        let urlAdocs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let urlAlArchivo = urlAdocs.appendingPathComponent(nombre)
        do {
            try bytes.write(to: urlAlArchivo)
        }
        catch {
            print ("no se puede salvar la imagen \(error.localizedDescription)")
        }
    }
    
    // mostrar archivo
    func mostrarArchivo() {
        //setting home directory
        let homeDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let rutaArchivo = URL(string: homeDirURL.path + "/" + fileName){
            if FileManager.default.fileExists(atPath: rutaArchivo.path) {
                let request = URLRequest(url: URL(fileURLWithPath: rutaArchivo.path))
                        DispatchQueue.main.async {
                            self.nombreArchivo.text = self.fileName
                            self.webview.load(request)
                            self.indicator.stopAnimating()
                        }

            } else {
                print(fileName + " no existe")
            }
        }
        self.indicator.startAnimating()
    }
    
}

