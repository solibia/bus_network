/**
* Name: ReseauDeBus
* Author: basile
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model ReseauDeBus

global {
    /** Insert the global definitions, variables and actions here */
    // shapefile : ligne1
    file shape_file_ligne1 <- file("../includes/ligne1.shp");
    // shapefile : ligne2
    file shape_file_ligne2 <- file("../includes/ligne2.shp");
   	 // shapefile : ligne3
    file shape_file_ligne3 <- file("../includes/ligne3.shp");
   		 // shapefile : ligne4
    file shape_file_ligne4 <- file("../includes/ligne4.shp");
    
   			 // shapefile : ligne7
    file shape_file_road <- file("../includes/lines.shp");
    // shapefile : les points d'arrets
    file shape_file_pointarret <- file("../includes/roadpoints.shp");
    // shapefile : building
    file shape_file_building <- file("../includes/buildings.shp");
    geometry shape <- envelope(shape_file_road);
    //reading some of the shapefile attributes
    list lst_feux <- Feux_tricolores as list;//regroupe les points d'arrets du feu
    
    
    // definition de variable globale
    int duree_aux_arret<-15;
    int duree_aux_station<-55;
    //taille de bus
    float taille_bus<-14.0;
    //temps d'apparition de vehicule;
    int temps_apparition<-10;
    //temps moyen de bus pour un tour
    float temps_moyen_bus;
    //Nomber total de passager sur la ligne
    int nombre_total_passager;
    //distance pour arret
    float distance_arret<-10.0;
    //nombre de bus par ligne
    int nombre_bus_ligne<-3;
    //Nombre de passagers total du systeme
    int nombre_passagers <- 500;
    
    
    init{
   	 create StationAbstract from: shape_file_pointarret with:[typepoint::string(read("highway")),typeligne::string(read("lignetype"))]{
   		 if(typepoint='bus_stop'){
   			 //color<-#red;
   			 create pointArret{
   				 color<-#red;
   				 typepoint<-'bus_stop';
   				 set typeligne<-myself.typeligne;
   				 set location<-myself.location;
   			 }
   		 }
   		 if(typepoint="bus_station"){
   			 /*color<-#green;*/
   			 create Station{
   				 color<-#black;
   				 typepoint<-'bus_station';
   				 set location<-myself.location;
   				 set typeligne<-myself.typeligne;
   			 }
   			 
   		 }
   		 if(typepoint="traffic_signals"){
   			 /*color<-#green;*/
   			 create Feux_tricolores{
   				 color<-#green;
   				 typepoint<-'traffic_signals';
   				 set location<-myself.location;
   				 set typeligne<-myself.typeligne;
   				 
   			 }
   			 
   		 }
   	 }
   	 
   	 create ligne from: shape_file_ligne1{
   		 //affecter un identifiant a la ligne
   		 idLigne<-1;
   		 list<Station> my_list_Station<- Station where (each.typeligne='1');
   		 listFeux <- Feux_tricolores where (each.typeligne='1');
   		 listPointArret <- pointArret where (each.typeligne='1');
   		 depart<-first(my_list_Station);
   		 arrive<-last(my_list_Station where (each !=depart));
   		 
   	 }
   	 
   	 create ligne from: shape_file_ligne2{
   		 idLigne<-2;
   		 list<Station> my_list_Station<- Station where (each.typeligne='2');
   		 listFeux <- Feux_tricolores where (each.typeligne='2');
   		 listPointArret <- pointArret where (each.typeligne='2');
   		 depart<-first(my_list_Station);
   		 arrive<-last(my_list_Station where (each !=depart));
   	 }
   	 create ligne from: shape_file_ligne3 {
   		 idLigne<-3;
   		 list<Station> my_list_Station<- Station where (each.typeligne='3');
   		 listFeux <- Feux_tricolores where (each.typeligne='3');
   		 listPointArret <- pointArret where (each.typeligne='3');
   		 depart<-first(my_list_Station);
   		 arrive<-last(my_list_Station where (each !=depart));
   	 }
   	 create ligne from: shape_file_ligne4{
   		 idLigne<-4;
   		 list<Station> my_list_Station<- Station where (each.typeligne='4');
   		 listFeux <- Feux_tricolores where (each.typeligne='4');
   		 listPointArret <- pointArret where (each.typeligne='4');
   		 depart<-first(my_list_Station);
   		 arrive<-last(my_list_Station where (each !=depart));
   	 }
   	 
   	 create lines from: shape_file_road;
   	 create building from: shape_file_building;
   	 ask ligne{
   		 
   	 }
   	 let listligne value: ligne;
   	 loop lg over: listligne {
   		 create Bus number:nombre_bus_ligne{
   			 color<-#yellowgreen;
   			 size<-taille_bus;
   			 speed<-rnd(2);
   			 charge_max<-rnd(100)+30;
   			 charge_courant<-0;
   			 charge_totale<-0;
   			 duree_point<-duree_aux_arret;
   			 duree_station<-duree_aux_station;
   			 ligne_bus<-lg;
   			 depart<-ligne_bus.depart;
   			 station<-ligne_bus.arrive;
   			 set location<-depart;   	 
   		 }
   	 }
    
   	 
   	 create Passagers number:nombre_passagers{
   		 
   		 pointArret mydepart<-one_of(pointArret);
   		 set depart<-mydepart;
   		 set arrive<-one_of(pointArret where (each.typeligne=mydepart.typeligne and each !=mydepart ));
   		 set location<-mydepart;
   			 
   	 }
    }
    
}

species pointDepart {
    rgb color <- #white;
    aspect basic {
   	 draw geometry: shape color: color;
    }
}
species StationAbstract {
    string typeligne;
    string typepoint;
    rgb color <- #white;
    aspect basic {
   	 draw geometry: shape color: color;
    }
}
species Station parent: StationAbstract {
    aspect basic {
   	 draw shape color: color;
   	 draw circle(3) depth:40 color:#black; // poteau de la station
   	 draw square(10) rotate:90 at:{location.x,location.y,40} color:#blue; // dessin du ponceau de la station avec l'aspect 3D
    }    
}

species pointArret parent: StationAbstract {

    aspect basic {
   	 draw geometry: shape color: #blue;
    }
}
// species ligne

species ligne{
    // identifiant de la ligne
    int idLigne;
    Station depart;
    Station arrive;
    list<Feux_tricolores> listFeux;
    list<pointArret> listPointArret;
    rgb color <- #black;
    aspect basic {
   	 draw geometry: shape+20 color: color;
    }
}
// species line plan
species lines{
    rgb color <- #FFA500;
    aspect basic {
   	 draw geometry: shape color:color;
    }
}

species building {   
	int size <-70+rnd(30); //ajout
	rgb color <- #582900;
	aspect basic {
    	draw shape color: color depth:size; // dessin du building avec l'aspect 3D
	}
}
// species Feux_tricolores

species Feux_tricolores parent: StationAbstract{
    int counter <- 0;
    rgb current_color <- #red;
    int red_duration <- 70;
    int green_duration <- 100;
    
    reflex fonction {
   	 counter <- counter +1;
   	 if((current_color = #red) and (counter >= red_duration)){
   		 //changer la couleur
   		 current_color <- #green;
   		 //reinitialiser le compteur
   		 counter <- 0;
   	 }else if((current_color = #green) and (counter >= green_duration)){
   		 //changer la couleur
   		 current_color <- #red;
   		 //reinitialiser le compteur
   		 counter <- 0;   	 
   	 }
    }
    
    aspect basic {
   	 //draw geometry: shape color: current_color;
   	 draw circle(3) depth:60; // dessin du poteau du feux tricolore
   	 draw sphere(4) color:current_color at:{location.x,location.y,61}; // dessin de la lampe du feux
   	 draw sphere(4) color:current_color at:{location.x,location.y,65}; // dessin de la lampe du feux
   	 draw sphere(4) color:current_color at:{location.x,location.y,69}; // dessin de la lampe du feux
   	 draw square(10) color:#black at:{location.x,location.y,58};// dessin du panneau du feux
   	 draw square(10) color:#black at:{location.x,location.y,72}; // dessin du panneau du feux
    }
}

// species Passagers

species Passagers{
    rgb color <- #violet;  //couleur de la voiture
    float size <- 23.0;  //taille de la voiture
    pointArret arrive;
    pointArret depart;
    Bus bus <- nil;
    
    reflex monter when: (bus = nil) {
   	 // Determiner le premier
   	 let my_bus value: first(list(Bus) where((self distance_to each <= distance_arret) and (each.etat!=0)));
   	 if(my_bus!=nil){
   		 let my_bus_charge_max value: my_bus.charge_max;
   		 let my_bus_charge_courant value: my_bus.charge_courant;
   		 if(my_bus_charge_courant<my_bus_charge_max){
   			 bus<-my_bus;
   			 ask my_bus {
   				 charge_courant<-charge_courant+1;
   				 charge_totale<-charge_totale+1;
   			 }
   			 size<-0;
   		 }
   	 }
   	 
   	 
    }
    reflex descendre when: (bus != nil) {
   	 //float dist <- bus distance_to self;
   	 if((bus distance_to self.arrive<= distance_arret) and (bus.etat!=0)){
   		 ask bus{
   			 charge_courant<-charge_courant-1;
   		 }
   		 bus<-nil;
   		 set location<-arrive;
   		 set size<-22;
   		 set color<-#blueviolet;
   	 }
   	 
    }
    aspect basic {
   	 draw circle(size) color:color;
    }
}
// species MoyensTransports

species MoyensTransports{
    float size <- rnd(2) + 1.0;    //taille
    float speed; //  Vitesse     
    float speed_min <- 3.0;
    float speed_max <- 12.0;
    rgb color <- rnd_color(255);
    Feux_tricolores feu <- nil;
}
// species Moto

species Moto skills:[moving] parent: MoyensTransports{
    int count_double <- 0;

    reflex se_deplacer{
   	 //do goto target: arrive on: parcours_bus speed:speed;
    }
    reflex arret_points{
   	 
    }
    reflex arret_station{
   	 
    }
    reflex arret_feux_rouge{
   	 
    }
    reflex quitter_arrets{
   	 
    }
    reflex quitter_station{
   	 
    }
    reflex eviter_obstacle{
   	 
    }
    
    aspect basic {
   	 draw circle(size) color:color;
    }
}

species Voiture skills:[moving] parent: MoyensTransports{
    int count_double <- 0;

    reflex se_deplacer{
   	 
    }
    reflex arret_points{
   	 
    }
    reflex arret_station{
   	 
    }
    reflex arret_feux_rouge{
   	 
    }
    reflex quitter_arrets{
   	 
    }
    reflex quitter_station{
   	 
    }
    reflex eviter_obstacle{
   	 
    }
    
    aspect basic {
   	 draw circle(size) color:color;
    }
}

species Bus skills:[moving] parent: MoyensTransports{
    int charge_max; // Quantité maximum du passager dans le bus
    int charge_courant; // Quantité actuelle de passagers dans le bus
    int charge_totale; // Quantité totale de passagers pris durant le parcours du bus
    int etat; // état du bus (arrêt aux points ou à la station) 0 roule, 1 stop point, 2 stop station, 3 arret au feux
    int duree_point; // Temps d’arret au point d’arret
    int duree_point_courant <- 0; // Temps d’arret au point d’arret
    int duree_station; // temps d’arret a la station
    int duree_station_courant  <- 0 ; // temps d’arret a la station
    int duree_totale; // temps totale de circulation effectuée par le bus
    float distance_courante; // distance déjà parcourue par le bus
    float distance_totale; // distance totale parcourue par le bus
    ligne ligne_bus;  // ligne de bus
    Station depart;
    Station station;
    bool aller<-true; // Aller ou retour (Vrai pour Aller et Faux pour Retour)
	float nombre_tour  <- 0.0; // Nombre de tours
	float temps_avant_depart <- 10*rnd(5)+1.0 ; // temps avt demarrer
    
    
    reflex se_deplacer{
   	 if (temps_avant_depart<=0){
   	 	do goto target: station on: ligne_bus speed:speed;  
		duree_totale <- duree_totale+1; 		
		distance_courante <- self distance_to depart;
   		   
   	 }else{
   		 temps_avant_depart<-temps_avant_depart-1;
   	 }
   		 
    }
    
    reflex arret_points{
   	 let my_pointArret value: first(ligne_bus.listPointArret where (self distance_to each <= distance_arret));
   	 if(my_pointArret!=nil){
   		 set etat<-1;
   		 set speed<-0.0;
   		 set duree_point_courant<-duree_point_courant+1;
   	 }
    }
    
    reflex arret_station{   	 
   	 ask station {
   		 float dist <- self distance_to myself;
   		 if(dist<=distance_arret){
   			 myself.etat<-2;
   			 myself.speed<-0.0;
   			 myself.duree_station_courant<-myself.duree_station_courant+1;
   		 }
   	 }
    }
    //Cette fonction verifie si le bus est à un feu tricolore
    reflex verifier_sibus_est_au_point_arret_feu{
   	 
   	 loop paf over: ligne_bus.listFeux{
   		 if self.shape overlaps paf.shape{
   			 set feu <- paf;
   		 }
   	 }    
    }   	 
    //cette fonction permet aux agents de s'arreter si le feu est rouge sinon de passer
    reflex arret_feux_rouge when: feu!=nil {
   	 ask feu {
   		 if(self.current_color=#red){
   			 myself.etat<-3;
   			 myself.speed<-0.0;
   		 }
   	 }   	 
    }    
    //Cette fonction permet de continuer a la suite d'un arret à un feux rouge
    reflex quitter_feux_rouge when: feu!=nil {
   	 ask feu {
   		 if(self.current_color=#green){
   			 myself.etat<-3;
   			 myself.speed <- rnd(myself.speed_max - myself.speed_min)+ myself.speed_min;
   			 myself.feu <- nil;
   		 }
   	 }   	 
    }
    //Cette fonction permet de continuer a la suite d'un arret à un point d'arret
    reflex quitter_arrets when: duree_point_courant>=duree_point{
   	 speed <- rnd(speed_max - speed_min)+ speed_min;
   	 do goto target: station on: ligne_bus speed:speed;
   	 duree_point_courant<-0;
   	 etat <- 0;   	 
    }
    
    //Cette fonction permet de continuer a la suite d'un arret dans une station    
    reflex quitter_station when: duree_station_courant>=duree_station{
   	 speed <- rnd(speed_max - speed_min)+ speed_min;
   	 do retourner;
   	 //do goto target: station on: ligne_bus speed:speed;
   	 duree_station_courant<-0;
   	 etat <- 0;
    }
    
    //Cette fonction permet de ralentir afin d'éviter les accidents de la circulation
    reflex eviter_obstacle{
   	 
    }

    //Cette action permet au bus de retourner lorqu'il arrive à la gar    
	action retourner {
		aller <- aller ? false:true;
		let x_station <- depart; 
		depart <- station;
		station <- x_station;
		nombre_tour  <- nombre_tour + 0.5;		
		set distance_totale <- distance_totale + distance_courante;
		set distance_courante <- 0.0;		
		//write "Distance total "+distance_totale;		
		write "Distance total de "+nombre_tour +" tours vaut "+distance_totale;				
		do goto target: station on: ligne_bus speed:speed;		
	}
    
    aspect basic {
   	 draw square(8) depth:10 color:color rotate:90;
    }
}





experiment ReseauDeBus type: gui {
    /** Insert here the definition of the input and output of the model */
    
    
    output {
   	 display Circulation type:opengl{
   		 species lines aspect:basic;
   		 species ligne aspect:basic;
   		 species building aspect:basic;
   		 
   		 //species StationAbstract aspect:basic;
   		 species pointArret aspect:basic;
   		 species Passagers aspect:basic;
   		 species Station aspect:basic;
   		 species Feux_tricolores aspect:basic;
   		 species Bus aspect:basic;
   		 
   		 
   	 }
		display nombre_passagers_bus refresh:every(5){
			chart 'Nombre de passagers courantes du bus'
				type: 'series'{
				loop unBus over: list(Bus){
					data unBus.name value: unBus.charge_courant color: rnd_color(255);
					}
			    }
		   }			   
		display distance_total refresh:every(5){
			chart 'distance total moyen des bus'
				type: 'series'{
				loop unBus over: list(Bus){
					data unBus.name value: unBus.distance_totale+unBus.distance_courante color: rnd_color(255);
					}
			    }
		   }			   
	    display "vitesse_moyenne_bus" refresh:every(5){
	        chart "vitesse moyenne par bus" type: series {
			loop unBus over: list(Bus){
				data unBus.name value: unBus.distance_totale/max([unBus.duree_totale,1]) color: rnd_color(255);
				}
			}
	    }   	 
    }
}


