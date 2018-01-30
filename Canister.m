classdef Canister
    properties
        level
        viscosity
        period
        pwm
        maxpressure
        tube_radius
        pump_length
        log
    end
    methods
        function obj = Canister(level, viscosity, period, maxpressure, tube_radius, pump_length)
            obj.level = level;
            obj.viscosity = viscosity;
            obj.period = period;
            obj.maxpressure = maxpressure;
            obj.tube_radius = tube_radius;
            obj.pump_length = pump_length;
            obj.log = [level];
        end
        
        function dispense(obj, amount)
            ki = - 1/8;
            kd = 3;
            kp = 2;
            target = obj.level - amount;
            error = amount;
            last_error = amount;
            integral = 0;
            while(abs(error) > 0.00001)
                error = obj.level - target;
                integral = integral + error;
                derivative = error - last_error;

                val = ki * integral + kp * error + kd * derivative;
                if val < 0
                    val = 0;
                elseif val > obj.period
                    val = obj.period;
                end
             
                obj.pwm = val;
                
                last_error = error;
                tick(); 
            end
        end
        
        function tick(obj)
            pressure = obj.pwm / obj.period * obj.maxpressure;
            flowrate = pi * obj.tube_radius .^ 4 * pressure / (8 * obj.viscosity * obj.pump_length);
            obj.level = obj.level - flowrate * obj.period;
            obj.log = [obj.log, obj.level];
        end
        
        function resetLevel(obj, level)
            obj.level = level;
            obj.log = [level];
        end
    end
end
% http://ca.grundfos.com/about-us/news-and-press/news/fluid-viscosity-and-density-a-pump-user-s-guide.html
% https://en.wikipedia.org/wiki/Hagen%E2%80%93Poiseuille_equation          

