function main()
    %--this copy all line from input file till varriable convertFromLine
    %and translate to new form(SFCN) until line variable convertStopInLine
    %and copy remind line exacly to new file. for size detection you have
    %to asign input size for first layer.
    
    clc;close all;clear all;
    global net
    global outFile
    global currentLine
    %%--------------setting ---------------------------------------------------
    addInputFile='/home/nasr/Desktop/Skin/Model/Model27/temp.prototxt';
    addOutputFile='/home/nasr/Desktop/Skin/Model/Model27/train_PFCN_New.prototxt';
    convertFromLine=33;
    convertStopInLine=684;
    
    %%-------------------------------------------------------------------------
    currentLine=0;
    inFile = fopen(addInputFile);
    outFile = fopen(addOutputFile,'w');
    for i=1:convertFromLine    
        txtLine = fgets(inFile);
        currentLine=currentLine+1;
        fprintf(outFile, txtLine);    
    end  
    
    net=[];
    net{1}.type='notype';
    net{1}.top='GlobalPatch';
    net{1}.level=0;
    net{1}.size=186;
    net{1}.numOut=3;
    

    

    while(1==1)

        [layerTxt]=GetNewLayer(inFile); 
        if(currentLine>convertStopInLine)
            break;
        end
        Interperator(layerTxt);   
    end
    
  
    for i=1:size(layerTxt,2)
        line=layerTxt{i};
        fprintf(outFile, line);            
    end       
    txtLine = fgets(inFile);    
    while ischar(txtLine)
        currentLine=currentLine+1;
        fprintf(outFile, txtLine);    
        txtLine = fgets(inFile);
    end      
    fclose(inFile);
    fclose(outFile);



end
function Interperator(layerTxt)
    global net
    global outFile
   layer=InterpretLayer(layerTxt);
   if(strcmp(layer.type,'Convolution'))
       InterpretConvLayer(layerTxt);       
   end
   if(strcmp(layer.type,'ReLU'))
       InterpretReluLayer(layerTxt);       
   end   
   if(strcmp(layer.type,'Pooling'))
       InterpretPoolingLayer(layerTxt);       
   end  
   if(strcmp(layer.type,'Crop'))
       InterpretCropLayer(layerTxt);       
   end  
   if(strcmp(layer.type,'Concat'))
       InterpretConcatLayer(layerTxt);       
   end  
   if(strcmp(layer.type,'BatchNorm'))
       InterpretBatchNormLayer(layerTxt);       
   end
   if(strcmp(layer.type,'Scale'))
       InterpretScaleLayer(layerTxt);       
   end   
   
end
function [res] = GetNewLayer(inFile)
    global currentLine

    res=cell(1);
    i=1;
    while(1==1)
        line = fgets(inFile);
        currentLine=currentLine+1;
        if(CheckFormatLine(line)==1)
            disp('Error:');
            line
        end
            
        res{i}=line;
        i=i+1;
        temp=strsplit(line,'{');  
        if(size(temp,2)>1)
            break;
        end                           
    end
    numAcolad=1;    
    while(numAcolad>0)
        line = fgets(inFile);
        currentLine=currentLine+1;
        
        if(CheckFormatLine(line)==1)
            disp('Error:');
            line
        end  
        res{i}=line;
        i=i+1;
        temp=strsplit(line,'{');  
        if(size(temp,2)>1)
            numAcolad=numAcolad+1;
        end 
        temp=strsplit(line,'{{');  
        if(size(temp,2)>1)
            numAcolad=numAcolad+2;
        end         
        temp=strsplit(line,'}');  
        if(size(temp,2)>1)
            numAcolad=numAcolad-1;
        end 
        temp=strsplit(line,'}}');  
        if(size(temp,2)>1)
            numAcolad=numAcolad-2;
        end         
        
    end    
    
    
end
function error = CheckFormatLine(line)
    error=0;
    temp1=strsplit(line,'{');  
    temp2=strsplit(line,'}');
    if(size(temp1,2)>1 && size(temp2,2)>1)
        error=0;
    end
end
function layer=InterpretLayer(layerTxt) 
    layer.name='';
    layer.type='';
    layer.top='';
    layer.bottom='';
    layer.level='';
    layer.stride='';
    layer.kernel='';
    layer.numOut='';
    layer.bottom2='';
    layer.offset=-1;
    
    
    
    
    for i=1:size(layerTxt,2)
        line=layerTxt{i};
        %--------------for type layer
        temp=strsplit(line,'"Scale"');  
        if(size(temp,2)>1)
            layer.type='Scale';
        end         
        temp=strsplit(line,'"BatchNorm"');  
        if(size(temp,2)>1)
            layer.type='BatchNorm';
        end         
        temp=strsplit(line,'"Convolution"');  
        if(size(temp,2)>1)
            layer.type='Convolution';
        end 
        temp=strsplit(line,'"ReLU"');  
        if(size(temp,2)>1)
            layer.type='ReLU';
        end 
        temp=strsplit(line,'"Pooling"');  
        if(size(temp,2)>1)
            layer.type='Pooling';
        end 
        temp=strsplit(line,'"Crop"');  
        if(size(temp,2)>1)
            layer.type='Crop';
        end 
        temp=strsplit(line,'"Concat"');  
        if(size(temp,2)>1)
            layer.type='Concat';
        end         
        %--------------for top & bottom connettion
        if(length(findstr(line, 'top:'))>0)
            temp=strsplit(line,'"');  
            layer.top=temp{2};
        end         
        if(length(findstr(line, 'bottom:'))>0)
            if(length(layer.bottom)>0)
                temp=strsplit(line,'"');  
                layer.bottom2=temp{2};
            else
                temp=strsplit(line,'"');  
                layer.bottom=temp{2};                
            end
        end  
        %-----
        if(length(findstr(line, 'name:'))>0)
            temp=strsplit(line,'"');  
            layer.name=temp{2};
        end        
        if(length(findstr(line, 'stride:'))>0)
            temp=strsplit(line,':');  
            layer.stride=temp{2};
        end           
        if(length(findstr(line, 'kernel_size:'))>0)
            temp=strsplit(line,':');  
            layer.kernel=temp{2};
        end    
        if(length(findstr(line, 'num_output:'))>0)
            temp=strsplit(line,':');  
            layer.numOut=str2num(temp{2});
        end  
        if(length(findstr(line, 'offset:'))>0)
            temp=strsplit(line,':');  
            layer.offset=str2num(temp{2});
        end    
        
        
        
        
    end
end
function layer=FindPreLayer(currentNode)
    global net
    layer='';
    if(length(net)==1)
        return;
    end
    for i=1:length(net)
        if(strcmp(net{i}.top,net{currentNode}.bottom))
            layer=net{i};
            return;
        end
    end

end
function AddLayerTextToOutputFile(layerTxt)
    global outFile
    for i=1:size(layerTxt,2)
        fprintf(outFile, layerTxt{i});            
    end
end   
function InterpretConvLayer(layerTxt)
    global net  
    global outFile
    
    layer=InterpretLayer(layerTxt);
    net{length(net)+1}=layer;
    
    preLayer=FindPreLayer(length(net))
    if(length(preLayer)==0  || (preLayer.level==0  && ~strcmp('Pooling',preLayer.type)))
        AddLayerTextToOutputFile(layerTxt);
        net{length(net)}.level=0;
        net{length(net)}.size=preLayer.size-str2num(layer.kernel)+1; 
        sizeFeature=net{length(net)}.size;
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)}.numOut) '\n'] );            

        return
    else
        if(strcmp('Pooling',preLayer.type))
            level=preLayer.level+1;
        else
            level=preLayer.level;                        
        end
        net{length(net)}.level=level;  
        layerTxt=ChangeTextLayer(layerTxt,'top:',['  top: "' layer.top '_T"\n']);                        
        AddLayerTextToOutputFile(layerTxt);
        sizeFeature=preLayer.size-str2num(layer.kernel)+1;        
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)}.numOut) '\n'] );                    
        InsertDeleteInvalidDataConvLayer(['valid_' layer.top],layer.top,[layer.top '_T'],level,str2num(layer.kernel)) 
        sizeFeature=sizeFeature-(str2num(layer.kernel)-1)*(2^level-1);        
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)}.numOut) '\n'] );                    
        net{length(net)}.size=sizeFeature;
        
    end
    
    
end
function InterpretReluLayer(layerTxt)
    global net  
    global outFile
    
    layer=InterpretLayer(layerTxt);
    net{length(net)+1}=layer;
    AddLayerTextToOutputFile(layerTxt);
    preLayer=FindPreLayer(length(net));
    net{length(net)}.level=preLayer.level;
    net{length(net)}.size=preLayer.size; 
    sizeFeature=net{length(net)}.size;
    fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)-1}.numOut) '\n'] );                    

end
function layerTxt=ChangeTextLayer(layerTxt,oldTxt,newTxt)
    for i=1:size(layerTxt,2)
        if(length(findstr(layerTxt{i},oldTxt))>0)
            layerTxt{i}=newTxt;
            return;
        end         
    end
end
function InsertReshapePoolingLayer(name,top,bottom,level)
    global outFile
    fprintf(outFile,'layer {\n');            
    fprintf(outFile,'  type: "Python"\n');            
    fprintf(outFile,['  name: "' name '"\n']);   
    fprintf(outFile,['  top:  "' top '"\n']);            
    fprintf(outFile,['  bottom: "' bottom '"\n']);            
    
    fprintf(outFile,'  python_param {\n');            
    fprintf(outFile,'    module: "ReshapeLayers"\n');            
    fprintf(outFile,'    layer: "ReshapePoolingLayer"\n');            
    fprintf(outFile,['    param_str: "''level'': ' num2str(level) '"\n']);            
    fprintf(outFile,'  }\n');            
    fprintf(outFile,'}\n');                
end
function InterpretPoolingLayer(layerTxt)
    global net   
    global outFile
    
    layer=InterpretLayer(layerTxt);
    net{length(net)+1}=layer;
    
    preLayer=FindPreLayer(length(net));

    if(strcmp('Pooling',preLayer.type))
        level=preLayer.level+1;
    else
        level=preLayer.level;                        
    end    
    
    if(str2num(layer.stride)==2)
        level=level;
        layerTxt=ChangeTextLayer(layerTxt,'name:',['  name: "' layer.name '_1"\n']);                        
        layerTxt=ChangeTextLayer(layerTxt,'stride:','    stride: 1\n');
        layerTxt=ChangeTextLayer(layerTxt,'kernel_size:','    kernel_size: 2\n');        
        layerTxt=ChangeTextLayer(layerTxt,'top:',['  top: "' layer.top '_1"\n']);                
        AddLayerTextToOutputFile(layerTxt);
        sizeFeature=preLayer.size-1;         
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)}.numOut) '\n'] );                                    
        InsertReshapePoolingLayer(['reshape_' layer.top '_1'],[layer.top ],[ layer.top '_1'],level)
        sizeFeature=sizeFeature-2^level+1;        
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(preLayer.numOut) '\n'] );                            
        layer.size=sizeFeature;

        layer.level=level;
        net{length(net)}=layer;        
    end
    if(str2num(layer.stride)==4)
        level=level;
        layerTxt=ChangeTextLayer(layerTxt,'name:',['  name: "' layer.name '_1"\n']);                        
        layerTxt=ChangeTextLayer(layerTxt,'stride:','    stride: 1\n');
        layerTxt=ChangeTextLayer(layerTxt,'kernel_size:','    kernel_size: 2\n');        
        layerTxt=ChangeTextLayer(layerTxt,'top:',['  top: "' layer.top '_1"\n']);                
        AddLayerTextToOutputFile(layerTxt);
        sizeFeature=preLayer.size-1;
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(preLayer.numOut) '\n'] );                            
        InsertReshapePoolingLayer(['reshape_' layer.top '_1'],['reshape_' layer.top '_1'],[ layer.top '_1'],level);
        sizeFeature=sizeFeature-2^level+1;        
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(preLayer.numOut) '\n'] ); 
        layer.size=sizeFeature;
       
        
        
        level=level+1;        
        layerTxt=ChangeTextLayer(layerTxt,'name:',['  name: "' layer.name '_2"\n']);                                
        layerTxt=ChangeTextLayer(layerTxt,'top:',['  top: "' layer.top '_2"\n']);  
        layerTxt=ChangeTextLayer(layerTxt,'bottom:',['  bottom: "reshape_' layer.top '_1"\n']);                        
        AddLayerTextToOutputFile(layerTxt);     
        sizeFeature=sizeFeature-1;
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(preLayer.numOut) '\n'] );                            
        InsertReshapePoolingLayer(['reshape_' layer.top '_2'],[ layer.top ],[ layer.top '_2'],level)
        sizeFeature=sizeFeature-2^level+1;        
        fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(preLayer.numOut) '\n'] );                            
        
        layer.level=level;
        layer.size=sizeFeature;
        net{length(net)}=layer;
        
        
    end
    
end
function InsertDeleteInvalidDataConvLayer(name,top,bottom,level,kernel)
    global outFile
    fprintf(outFile,'layer {\n');            
    fprintf(outFile,'  type: "Python"\n');            
    fprintf(outFile,['  name: "' name '"\n']);   
    fprintf(outFile,['  top:  "' top '"\n']);            
    fprintf(outFile,['  bottom: "' bottom '"\n']);            
    
    fprintf(outFile,'  python_param {\n');            
    fprintf(outFile,'    module: "ReshapeLayers"\n');            
    fprintf(outFile,'    layer: "DeleteInvalidDataConvLayer"\n');            
    fprintf(outFile,['    param_str: ''{"level": ' num2str(level) ',"kernel_size": ' num2str(kernel) '}''\n']);            
    fprintf(outFile,'  }\n');            
    fprintf(outFile,'}\n');                
end
function InterpretCropLayer(layerTxt)
    global net  
    global outFile
    
    layer=InterpretLayer(layerTxt);
    net{length(net)+1}=layer;

    
    preLayer=FindPreLayer(length(net))
    
    if(strcmp('Pooling',preLayer.type))
        level=preLayer.level+1;
    else
        level=preLayer.level;                        
    end     
    net{length(net)}.level=level; 
    sizeFeature=preLayer.size-layer.offset*(2^(preLayer.level+1));   
    net{length(net)}.size=sizeFeature;
    layer=net{length(net)}
    InsertCropLayer(layer.name,layer.top,layer.bottom,layer.level,layer.offset);
    fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(preLayer.numOut) '\n'] );            
    
end
function InsertCropLayer(name,top,bottom,level,offset)
    global outFile
  
    fprintf(outFile,'#====================================================================================\n');            
    fprintf(outFile,'#======================================CROP==========================================\n');            
    fprintf(outFile,'#====================================================================================\n');            

    fprintf(outFile,'layer {\n');            
    fprintf(outFile,'  type: "Python"\n');            
    fprintf(outFile,['  name: "' name '"\n']);   
    fprintf(outFile,['  top:  "' top '"\n']);            
    fprintf(outFile,['  bottom: "' bottom '"\n']);            
    
    fprintf(outFile,'  python_param {\n');            
    fprintf(outFile,'    module: "ReshapeLayers"\n');            
    fprintf(outFile,'    layer: "CropInLevelLayer"\n');            
    fprintf(outFile,['    param_str: ''{"level": ' num2str(level) ',"offset": ' num2str(offset) '}''\n']);            
    fprintf(outFile,'  }\n');            
    fprintf(outFile,'}\n');                
end
    
function InterpretConcatLayer(layerTxt)
    global net  
    global outFile    
    fprintf(outFile,'#====================================================================================\n');            
    fprintf(outFile,'#======================================Concat========================================\n');            
    fprintf(outFile,'#====================================================================================\n');            
    
    layer=InterpretLayer(layerTxt);
    
    for i=1:size(layerTxt,2)
        line=layerTxt{i};
        %--------------for type layer
        if(length(findstr(line, 'bottom:'))>0)
            temp=strsplit(line,'"');  
            
            layer.bottom=temp{2};                
            for i=1:length(net)
                if(strcmp(net{i}.top,temp{2}))
                    tempLayer=net{i};
                    if(strcmp('Pooling',tempLayer.type))
                        level=tempLayer.level+1;
                    else
                        level=tempLayer.level;                        
                    end                       
                     InsertRestoreLayer(['Restore_' tempLayer.name] ,['Restore_' tempLayer.name],tempLayer.top,level);
                     sizeFeature=tempLayer.size;
                     fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(tempLayer.numOut) '\n'] );            
                     
                    break;
                end
            end
        end
        
    end    
    
    fprintf(outFile,'layer {\n');            
    fprintf(outFile,'  type: "Concat"\n');            
    fprintf(outFile,['  name: "' layer.name '"\n']);   
    fprintf(outFile,['  top:  "' layer.top '"\n']);      
    for i=1:size(layerTxt,2)
        line=layerTxt{i};
        %--------------for type layer
        if(length(findstr(line, 'bottom:'))>0)
            temp=strsplit(line,'"');  
            
            layer.bottom=temp{2};                
            for i=1:length(net)
                if(strcmp(net{i}.top,temp{2}))
                    tempLayer=net{i};
                    fprintf(outFile,['  bottom: "' ['Restore_' tempLayer.name] '"\n']);                     
                     
                    break;
                end
            end
        end
        
    end     
    fprintf(outFile,'}\n');                
end
function InsertRestoreLayer(name,top,bottom,level)
    global outFile  
    fprintf(outFile,'layer {\n');            
    fprintf(outFile,'  type: "Python"\n');            
    fprintf(outFile,['  name: "' name '"\n']);   
    fprintf(outFile,['  top:  "' top '"\n']);            
    fprintf(outFile,['  bottom: "' bottom '"\n']);            
    
    fprintf(outFile,'  python_param {\n');            
    fprintf(outFile,'    module: "ReshapeLayers"\n');            
    fprintf(outFile,'    layer: "RestoreLayer"\n');            
    fprintf(outFile,['    param_str: "''level'': ' num2str(level) '"\n']);            
    fprintf(outFile,'  }\n');            
    fprintf(outFile,'}\n');                
end

function InterpretBatchNormLayer(layerTxt)
    global net   
    global outFile
    
    layer=InterpretLayer(layerTxt);
    net{length(net)+1}=layer;
    
    preLayer=FindPreLayer(length(net));


    level=preLayer.level;                        
    
    AddLayerTextToOutputFile(layerTxt);
    sizeFeature=preLayer.size; 
    net{length(net)}.numOut=preLayer.numOut;
    net{length(net)}.size=preLayer.size;
    fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)}.numOut) '\n'] );                                    
    layer.size=sizeFeature;

    layer.level=level;
    net{length(net)}=layer;        
    
end
function InterpretScaleLayer(layerTxt)
    global net   
    global outFile
    
    layer=InterpretLayer(layerTxt);
    net{length(net)+1}=layer;
    
    preLayer=FindPreLayer(length(net)-1);


    level=preLayer.level;                        
    
    AddLayerTextToOutputFile(layerTxt);
    sizeFeature=preLayer.size;  
    net{length(net)}.numOut=preLayer.numOut;
    net{length(net)}.size=preLayer.size;    
    fprintf(outFile,['#' num2str(sizeFeature) '*' num2str(sizeFeature) '*' num2str(net{length(net)}.numOut) '\n'] );                                    
    layer.size=sizeFeature;

    layer.level=level;
    net{length(net)}=layer;        
    
end

