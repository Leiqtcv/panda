%==================================================================
%                               Monitor I/O bits micro controller
%==================================================================
%
% This monitors Input *and* Output bits of micro controller.
%
% This script can be called to create figure and to maintain it
%

%% which bits
Inbits = [1:8];
Outbits = [1:8];
Ninbits = numel(Inbits);
Noutbits = numel(Outbits);

%% if figure does not exist, create it 
HF = findobj('Tag','BitMonitor');
if isempty(HF)
	
    % figure
	HF = figure('Tag','BitMonitor','name','Micro Bit monitor','numbertitle','off','menubar','none');
	axis off
	axis ij
	
    % position out bits
	X = ones(Noutbits,1)*60*ceil(Noutbits/4);
	for I_r = 1:floor(Noutbits/4)
		X([((I_r-1)*4)+1:(I_r*4)]) = ones(4,1)*60*I_r;
	end
	X=X-50;
	Y = repmat([4:-1:1]',1,ceil(Noutbits/4));
	Y = Y(1:Noutbits)'*30;
	PosOut = [X Y ones(Noutbits,1)*60 ones(Noutbits,1)*30];
	
    % position in bits
	X = ones(Noutbits,1)*60*ceil(Noutbits/4);
	for I_r = 1:floor(Noutbits/4)
		X([((I_r-1)*4)+1:(I_r*4)]) = ones(4,1)*60*I_r;
	end
	X=X+max(PosOut(:,1))+10;
	Y = repmat([4:-1:1]',1,ceil(Noutbits/4));
	Y = Y(1:Noutbits)'*30;
	PosIn  = [X Y ones(Ninbits,1)*60 ones(Ninbits,1)*30];
	
    % place UI's and create handles
	uicontrol(gcf,'style','text','string','COM1:','position',[10 15 30 10]);
 	HuiOpenClose    = uicontrol(gcf,'style','text','string','n/a','position',[50 15 60 10]);
	HuiRun          = uicontrol(gcf,'style','pushbutton','string','eval','position',[120 10 30 20],'callback','IObitsmonitor;');
	HuiOutBit       = nan(1,Noutbits);
	HuiInBit        = nan(1,Ninbits);
	uicontrol('style','text','string','OUT','position',PosOut(1,:)+[0 10 70 10])
	for I_outbit = 1:Noutbits
		CUR_outbit = Outbits(I_outbit);
        str = ['Bit ' num2str(CUR_outbit)];
        if I_outbit == 4
            str = ['4 RA16_1 start'];
        elseif I_outbit == 3
            str = ['3 RP2_2 start'];
        elseif I_outbit == 2
            str = ['2 RP2_2 start'];
        end
		HuiOutBit(I_outbit) = uicontrol(gcf,'style','radiobutton','TooltipString',str,'string',str,'position',PosOut(I_outbit,:),'value',0,'enable','off','Tag',['OutBit' num2str(CUR_outbit)]);
	end
	uicontrol('style','text','string','IN','position',PosIn(1,:)+[0 10 70 10])
	for I_inbit = 1:Ninbits
		CUR_inbit = Inbits(I_inbit);
        str = ['Bit ' num2str(CUR_inbit)];
        if I_inbit == 3
            str = ['3 RP2_2 ready'];
        elseif I_inbit == 4
            str = ['4 RA16_1 ready'];
        elseif I_inbit == 5
            str = ['5-but'];
        end
		HuiInBit(I_inbit) = uicontrol(gcf,'style','radiobutton','TooltipString',str,'string',str,'position',PosIn(I_inbit,:),'value',0,'enable','off','Tag',['InBit' num2str(CUR_inbit)]);
	end
else
    
    % get UI handles
	HuiOutBit = nan(1,Noutbits);
	HuiInBit = nan(1,Ninbits);
	for I_outbit = 1:Noutbits
		CUR_outbit = Outbits(I_outbit);
		HuiOutBit(I_outbit) = findobj('Tag',['OutBit' num2str(CUR_outbit)]);
	end
	for I_inbit = 1:Ninbits
		CUR_inbit = Inbits(I_inbit);
		HuiInBit(I_inbit) = findobj('Tag',['InBit' num2str(CUR_inbit)]);
	end
end

%% update bit levels
[IObits, dummy] = micro_getValues(com,cmdPin, '');
if ischar(IObits) && isempty(IObits)
	IObits = 255;
	FLAG_open = 0;
else
	FLAG_open = 1;
end

% set com1 value
if FLAG_open == 1
	set(HuiOpenClose,'string','open','ForegroundColor','g')
else
	set(HuiOpenClose,'string','CLOSED','ForegroundColor','r')
end

% set levels per bit
for I_outbit = 1:Noutbits
	CUR_outbit = Outbits(I_outbit);
	if FLAG_open == 1;
		bit  = bitget(IObits, CUR_outbit+8);
		level = bit~=0;
		set(HuiOutBit(I_outbit),'enable','on','value',level)
	else
		set(HuiOutBit(I_outbit),'enable','off')
	end
end
for I_inbit = 1:Ninbits
	CUR_inbit = Inbits(I_inbit);
	if FLAG_open == 1;
		bit  = bitget(IObits, CUR_inbit);
		level = bit~=0;
		set(HuiInBit(I_inbit),'enable','on','value',level)
	else
		set(HuiOutBit(I_inbit),'enable','off')
	end
end

drawnow