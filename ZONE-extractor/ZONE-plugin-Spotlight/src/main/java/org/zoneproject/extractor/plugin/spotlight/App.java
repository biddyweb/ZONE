package org.zoneproject.extractor.plugin.spotlight;

/*
 * #%L
 * ZONE-plugin-Spotlight
 * %%
 * Copyright (C) 2012 ZONE-project
 * %%
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * #L%
 */
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import org.zoneproject.extractor.utils.Database;
import org.zoneproject.extractor.utils.Item;
import org.zoneproject.extractor.utils.Prop;
import org.zoneproject.extractor.utils.ZoneOntology;

/**
 *
 * @author Desclaux Christophe <christophe@zouig.org>
 */

public class App 
{
    private static final org.apache.log4j.Logger  logger = org.apache.log4j.Logger.getLogger(App.class);
    public static String PLUGIN_URI = ZoneOntology.PLUGIN_SPOTLIGHT;
    public static int SIM_DOWNLOADS = 50;
    
    public App(){
        String [] tmp = {};
        App.main(tmp);
    }
    
    public static void main(String[] args) {
        ArrayList<Item> items = null;
        Prop [] fr = {new Prop(ZoneOntology.PLUGIN_LANG, "\"fr\"")};
        Prop [] en = {new Prop(ZoneOntology.PLUGIN_LANG, "\"en\"")};
        
        AnnotationThread[] th;
        HashMap<String, ArrayList<Prop>> props; 
        while(true){
                    do{
                        props = new HashMap<String, ArrayList<Prop>>();
                        items = new ArrayList<Item>();
                        Item[] enItems = Database.getItemsNotAnotatedForPluginsWithDeps(PLUGIN_URI,en,SIM_DOWNLOADS);
                        Item[] frItems = Database.getItemsNotAnotatedForPluginsWithDeps(PLUGIN_URI,fr,SIM_DOWNLOADS);
                        if(enItems != null) items.addAll(Arrays.asList(enItems));
                        if(frItems != null) items.addAll(Arrays.asList(frItems));
                        
                        
                        if(items == null){
                            continue;
                        }
                        th = new AnnotationThread[items.size()];

                        logger.info("Spotlight has "+items.size()+" items to annotate");
                        for(int curItem = 0; curItem < items.size() ; curItem++){
                            th[curItem] = new AnnotationThread(items.get(curItem),props);
                            th[curItem].start();
                        }
                        for(int curItem = 0; curItem < items.size() ; curItem++){
                            try {
                                if(th[curItem] == null)continue;
                                th[curItem].join();
                            } catch (InterruptedException ex) {
                            logger.warn(ex);
                            }
                        }
                        Database.addAnnotations(props);

                    }while(items == null || items.size() > 0);
                logger.info("done");
            try{Thread.currentThread().sleep(1000);}catch(Exception ie){}
            
        }
    }
}


class AnnotationThread extends Thread  {
    private Item item;
    private HashMap<String, ArrayList<Prop>> props;
    private static final org.apache.log4j.Logger  logger = org.apache.log4j.Logger.getLogger(App.class);

    public AnnotationThread(Item item,HashMap<String, ArrayList<Prop>> props) {
        this.item = item;
        this.props = props;
    }
    public void run() {
        logger.info("[-] Start for item: "+item.getUri());
        //try {Thread.currentThread().sleep(5000);} catch (InterruptedException ex1) {}
        
        //Starting annotations downloading
        ArrayList<Prop> content= SpotlightRequest.getProperties(item);

        if(content != null){
            props.put(item.getUri(), new ArrayList<Prop>());
            props.get(item.getUri()).add(new Prop(App.PLUGIN_URI,"true"));
            props.get(item.getUri()).addAll(content);

        }else{
            logger.warn("Error while annotating" + item.getUri());
        }
        //logger.info("[+] Ended for item: "+item.getUri());
        
    }
}
