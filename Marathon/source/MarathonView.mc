using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Date;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Mon;

class MarathonView extends WatchUi.WatchFace {

	var backdrop;

    function initialize() {
        WatchFace.initialize();
    backdrop = new Rez.Drawables.backdrop();    
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (Application.getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // Update the view
        var view = View.findDrawableById("TimeLabel");
        view.setColor(Application.getApp().getProperty("ForegroundColor"));
        view.setText(timeString);
        
        setClockDisplay();
		setDateDisplay();
		setBatteryDisplay();
		setStepCountDisplay();
		setStepGoalDisplay();
		//setNotificationCountDisplay();
		setHeartrateDisplay();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        //dc.setColor(Gfx.COLOR_DK_RED,Gfx.COLOR_TRANSPARENT);
		//dc.fillRectangle(0, 0, 205, 23);
        dc.setColor(Gfx.COLOR_RED,Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        dc.drawLine(0, 24, 205, 24);
        dc.drawLine(0, 124, 205, 124);
        
        dc.drawLine(60, 0, 60, 24);
        dc.drawLine(145, 0, 145, 24);
        dc.drawLine(60, 124, 60, 148);
        dc.drawLine(145, 124, 145, 148);
        backdrop.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

    private function setClockDisplay() {
    	var clockTime = Sys.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel");
        view.setText(timeString);
    }

    private function setDateDisplay() {        
    	var now = Time.now();
		var date = Date.info(now, Time.FORMAT_LONG);
		var dateString = Lang.format("$1$ $2$, $3$", [date.month, date.day, date.year]);
		var dateDisplay = View.findDrawableById("DateDisplay");      
		dateDisplay.setText(dateString);	    	
    }

    private function setBatteryDisplay() {
    	var battery = Sys.getSystemStats().battery;				
		var batteryDisplay = View.findDrawableById("BatteryDisplay");      
		batteryDisplay.setText(battery.format("%d")+"%");	
    }

    private function setStepCountDisplay() {
    	var stepCount = Mon.getInfo().steps.toString();		
		var stepCountDisplay = View.findDrawableById("StepCountDisplay");      
		stepCountDisplay.setText(stepCount);		
    }

    private function setStepGoalDisplay() {
    	var stepGoalPercent = ((Mon.getInfo().steps).toFloat() / (Mon.getInfo().stepGoal).toFloat() * 100f);
		var stepGoalDisplay = View.findDrawableById("StepGoalDisplay");      
		stepGoalDisplay.setText(stepGoalPercent.format( "%d" ) + "%");	
    }

    private function setNotificationCountDisplay() {
    	var notificationAmount = Sys.getDeviceSettings().notificationCount;

		var formattedNotificationAmount = "";

		if(notificationAmount > 10)	{
			formattedNotificationAmount = "10+";
		}
		else {
			formattedNotificationAmount = notificationAmount.format("%d");
		}

		var notificationCountDisplay = View.findDrawableById("NotificationCountDisplay");      
		notificationCountDisplay.setText(formattedNotificationAmount);
    }

    private function setHeartrateDisplay() {
    	var heartRate = "";

    	if(Mon has :INVALID_HR_SAMPLE) {
    		heartRate = retrieveHeartrateText();
    	}
    	else {
    		heartRate = "";
    	}

		var heartrateDisplay = View.findDrawableById("HeartrateDisplay");      
		heartrateDisplay.setText(heartRate);
    }

    private function retrieveHeartrateText() {
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
		var currentHeartrate = heartrateIterator.next().heartRate;

		if(currentHeartrate == Mon.INVALID_HR_SAMPLE) {
			return "";
		}		

		return currentHeartrate.format("%d");
    }    
}
