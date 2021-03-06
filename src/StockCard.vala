/*
* Copyright (c) 2020 Your Organization (https://brendanperry.me)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Author <bperry@hey.com>
*/

public class StockCard: Gtk.Box {
    private Gtk.Label tickerLabel;
    private Gtk.Label priceLabel;
    private Gtk.Label percentageLabel;
    private GetApiData api;
    private Cards cards;
    private Gtk.Entry entry;
    private int index;
    private string key;

    public StockCard(string ticker, Cards cards, string price = "$0.00", string percent = "+0.00%", string key) {
        this.cards = cards;
        this.key = key;
        set_orientation (Gtk.Orientation.VERTICAL);
        this.get_style_context ().add_class ("card");

        api = new GetApiData ();

        if (ticker == "empty") {
            CreateEmptyCard (cards);
        } else {
            CreateNewCard (ticker, cards, price, percent);
        }
    }

    private void CreateEmptyCard (Cards cards) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.get_style_context ().add_class ("event");
        
        box.set_spacing (8);
        
        var ticker_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        tickerLabel = new Gtk.Label ("Add New");
        ticker_box.add (tickerLabel);
        ticker_box.get_style_context ().add_class ("ticker");
        ticker_box.show ();
        
        box.add (ticker_box);
        tickerLabel.show ();

        entry = new Gtk.Entry();

        entry.button_press_event.connect (() => {
            entry.is_focus = true;
            return true;
        });

        entry.max_length = 6;
        entry.set_max_width_chars (12);
        entry.set_width_chars (12);
        entry.xalign = (float) 0.5;
        entry.show ();

        entry.activate.connect (() => {
           string text = entry.text;
           cards.Remove (cards.GetLength () - 1);
           cards.AddCard (text);
           cards.AddCard ("empty");
        });

        box.add (entry);
        box.show ();
        
        add (box);
    }

    private void CreateNewCard (string ticker, Cards cards, string price, string percent) {
        var event_box = new Gtk.EventBox ();
        
        event_box.button_press_event.connect (() => {
            var pop = new Gtk.Popover (this);
            pop.set_modal (true);
            
            var button = new Gtk.Button.with_label ("Remove");
            button.get_style_context ().add_class ("destructive-action");
            
            button.clicked.connect (() => {
		        cards.Remove (GetIndex ());
	        });
	        
            pop.add (button);
            pop.show_all ();
            
            return true;
        });
        
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.get_style_context ().add_class ("event");
        event_box.add (box);
        
        box.set_spacing (10);
        
        var ticker_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        tickerLabel = new Gtk.Label (ticker.ascii_up (ticker.length));
        ticker_box.add (tickerLabel);
        ticker_box.get_style_context ().add_class ("ticker");
        ticker_box.show ();
        
        box.add (ticker_box);

        priceLabel = new Gtk.Label (price);
        percentageLabel = new Gtk.Label (percent);

        var box_price = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box_price.set_spacing (20);
        box_price.pack_start (priceLabel, false, false, 0);
        box_price.pack_end (percentageLabel, false, false, 0);

        tickerLabel.show ();
        priceLabel.show ();
        percentageLabel.show ();
        box_price.show ();
        box.show ();
        event_box.show ();

        box.add (box_price);
        
        add (event_box);
    }

    public void SetEntryFocus (string ticker) {
        if (ticker == "empty") {
            entry.is_focus = true;
        }
    }

    public void SetIndex (int index) {
        this.index = index;
    }

    public int GetIndex () {
        return index;
    }
    
    public string GetPrice () {
        return priceLabel.get_text ();
    }
    
    public string GetTicker () {
        return tickerLabel.get_text ();
    }
    
    public string GetPercentage () {
        return percentageLabel.get_text ();
    }
    
    public void UpdatePercentage (string percent) {
        percentageLabel.set_text (percent);
        // save cards now because the percent is only updated after the price
        Local.SaveCards (cards.GetCards ()); 
    }

    public void UpdatePrice () {
        if (tickerLabel.get_text () != "Add New") {
            api.HttpGet (this, tickerLabel.get_text (), key);
        }
    }

    public void SetPrice (string price) {
        priceLabel.set_text ("$" + price);
    }
    
    public Cards GetCards () {
        return cards;
    }
}
