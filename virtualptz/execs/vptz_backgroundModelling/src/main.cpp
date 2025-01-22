
//======================================================================================
//
// This program is used to view ground truth annotations while controlling the camera.
//
// Before running, set the input scenario/gt paths using the defines below.
//
//======================================================================================

#include "litiv/vptz/virtualptz.hpp"
#include <iostream>
#include <stdio.h>
#include <fstream>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define INPUT_SCENARIO_PATH        "/media/sf_CarpetaCompartidaVM/litiv_vptz_icip2015/scenario10/sea_malibu_cut.mp4"
//#define INPUT_SCENARIO_PATH        "/home/ubuntu/litiv_vptz_icip2015/scenario3/scenario3.avi"
//#define INPUT_SCENARIO_PATH        "/home/ubuntu/litiv_vptz_icip2015/videosfromyoutube/sphericam 2 360 video sample train.mp4"
//#define INPUT_SCENARIO_PATH        "/home/ubuntu/littlstar_ptz/360_beach.mp4"
//#define INPUT_SCENARIO_PATH        "/home/ubuntu/littlstar_ptz/360_car_plane.mp4"
//#define INPUT_SCENARIO_PATH        "/home/ubuntu/littlstar_ptz/360_train.mp4"
//#define INPUT_SCENARIO_PATH        "/home/ubuntu/littlstar_ptz/Sphericam2_Stich_Optimizer_Video_Sample.mp4"
#define INPUT_GT_SEQUENCE_PATH     "/home/ubuntu/litiv_vptz_icip2015/scenario3/gt/scenario3_fullbody01.yml"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// the values of the PTZ camera are taken from the datasheet of the SONY network camera SNC-RZ50N, pag 8
// http://www.networkwebcams.com/downloads/sony/nwlus_sony_snc-rz50n_ds.pdf?phpMyAdmin=07d80722534ef8cc190f6ff8c299d3a4
// PTZ_CAM_HORI_SPEED = 300 degrees/s
// PTZ_CAM_VERTI_SPEED = 300 degrees/s
// 30 fps

#define PTZ_CAM_HORI_MOVE  10 // 300 degrees per second/30 fps --> 10 degrees/frame
#define PTZ_CAM_VERTI_MOVE  10 // 300 degrees per second/30 fps --> 10 degrees/frame
#define PTZ_CAM_HORI_VERTI_MOVE_PIXELS 43 // if we move the cam 10 degrees, then the equivalent is 43 pixel
#define PTZ_CAM_ZOOM_MOVE  10 // no specified
#define PTZ_CAM_ZOOM_RANGE  5 // range where a random zoom is selected to be varied
#define PTZ_CAM_MIN_VERTI_FOV  70 // no specified
#define PTZ_CAM_MAX_VERTI_FOV  140 // no specified

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//typedef unsigned char byte;

cv::Point g_oLastMouseClickPos;


void moveCameraRight(vptz::Camera * oCamera){
	int horiAngleTemp = int(oCamera->Get(vptz::PTZ_CAM_HORI_ANGLE));
	int horiAngle = horiAngleTemp;
	horiAngle = horiAngleTemp - PTZ_CAM_HORI_MOVE; //move right
	oCamera->Set(vptz::PTZ_CAM_HORI_ANGLE, horiAngle);
}

void moveCameraLeft(vptz::Camera * oCamera){
	int horiAngleTemp = int(oCamera->Get(vptz::PTZ_CAM_HORI_ANGLE));
	int horiAngle = horiAngleTemp;
	horiAngle = horiAngleTemp + PTZ_CAM_HORI_MOVE; //move left
	oCamera->Set(vptz::PTZ_CAM_HORI_ANGLE, horiAngle);
}

void moveCameraDown(vptz::Camera * oCamera){
	int vertiAngleTemp = int(oCamera->Get(vptz::PTZ_CAM_VERTI_ANGLE));
	int vertiAngle = vertiAngleTemp;
	vertiAngle = vertiAngleTemp + PTZ_CAM_VERTI_MOVE; //move down
	oCamera->Set(vptz::PTZ_CAM_VERTI_ANGLE, vertiAngle);
}

void moveCameraUp(vptz::Camera * oCamera){
	int vertiAngleTemp = int(oCamera->Get(vptz::PTZ_CAM_VERTI_ANGLE));
	int vertiAngle = vertiAngleTemp;
	vertiAngle = vertiAngleTemp - PTZ_CAM_VERTI_MOVE; //move up
	oCamera->Set(vptz::PTZ_CAM_VERTI_ANGLE, vertiAngle);
}


void moveCameraZoom(vptz::Camera * oCamera, double varZoom){
	double vertiFOVTemp = double(oCamera->Get(vptz::PTZ_CAM_VERTI_FOV));
	//int vertiFOV = vertiFOVTemp;
	double vertiFOV = vertiFOVTemp + varZoom; //zoom out
	if(vertiFOV>=PTZ_CAM_MIN_VERTI_FOV && vertiFOV<=PTZ_CAM_MAX_VERTI_FOV){ //we update the zoom if it is between the valid values
		oCamera->Set(vptz::PTZ_CAM_VERTI_FOV, vertiFOV);
	}
	
}




int main(int /*argc*/, char** /*argv*/) 
{
    
	try 
	{
        cv::FileStorage oInputGT(INPUT_GT_SEQUENCE_PATH, cv::FileStorage::READ);
		
        vptz::Camera oCamera(INPUT_SCENARIO_PATH);
		
		//Pruebas leer imagen panorámica
		cv::VideoCapture panoCapture;
		panoCapture.open(INPUT_SCENARIO_PATH);
		cv::Mat oTestFrame1, panoImage;
		panoCapture.read(oTestFrame1);
		std::cout << "panoCapture frame size " << oTestFrame1.cols << "," << oTestFrame1.rows << std::endl;
		panoCapture >> panoImage;
		std::cout << "panoImage frame size " << panoImage.cols << "," << panoImage.rows << std::endl;
		
		//Prueba tipo de matriz
		cv::Mat m_oViewportFrame = cv::Mat(480, 640, CV_8UC4);
		std::cout << "m_oViewportFrame size " << m_oViewportFrame.size() << std::endl;
		
		
		
		
		/* Image variables */
		cv::Mat oCurrView;
		//cv::Mat CopyView;
		//CopyView = cv::Mat::zeros(480,640,CV_8UC4);
		cv::Mat Pano;
		Pano = cv::Mat::zeros(panoImage.rows,panoImage.cols,CV_8UC4);
		cv::namedWindow("Panoramic View");
        cv::imshow("Panoramic View", Pano);
		
		
		/* Define variables */
		double horiAngle, vertiAngle, tempHoriAngle, tempVertiAngle, normHoriAngle, normVertiAngle;
        int nFrameIdx;
		int cameraDirection = 1; //1 to go up y -1 to go down
		int cameraZoom = 1; //1 to go out y -1 to go in
		double vertiFOV, newVertiFOV, zoomMinR, zoomMaxR;
		bool bPaused = false;
		int i,j,NdxPixel,NdxUx,NdxVy;
		
		const unsigned long size1 = 4UL*640UL*480UL;
		unsigned char rgb[size1];	//To save image
		const unsigned long size2 = 640UL*480UL;
		double Ux[size2];			//To save Ux coordinates
		const unsigned long size3 = 640UL*480UL;
		double Vy[size3];			//To save Vy coordinates
		//double x[480*640],y[480*640],z[480*640];
		//int px,py;

		
		/* Initialize random seed: */
		srand(0);
		
		/* Define camera initial position */
        oCamera.Set(vptz::PTZ_CAM_FRAME_POS, 0);
		oCamera.Set(vptz::PTZ_CAM_HORI_ANGLE, 180);
		oCamera.Set(vptz::PTZ_CAM_VERTI_ANGLE, 0);
		oCamera.Set(vptz::PTZ_CAM_VERTI_FOV, 90.0);
		zoomMinR = 90.0;
		zoomMaxR = zoomMinR + PTZ_CAM_ZOOM_RANGE;
        oCurrView = oCamera.GetFrame();
        cv::namedWindow("Current View");
        cv::imshow("Current View", oCurrView);
        cv::waitKey(1);
		
		//Tamaño imagen cámara
		std::cout << "oCurrView size " << oCurrView.cols << "," << oCurrView.rows << std::endl;
			

		//Start
		int numSamples = 0;
		//std::cout << oCamera.Get(vptz::PTZ_CAM_FRAME_NUM) <<std::endl;
		
		
		for(nFrameIdx=0; nFrameIdx!=oCamera.Get(vptz::PTZ_CAM_FRAME_NUM); ++nFrameIdx) 
		{

			std::cout << "\t#" << nFrameIdx << std::endl;
            oCamera.Set(vptz::PTZ_CAM_FRAME_POS, nFrameIdx);
			

			
			while(true) 
			{
				
				//oCamera.GoToPosition(g_oLastMouseClickPos);
				oCurrView = oCamera.GetFrame();

				if(oCurrView.empty())
				{
					//std::cout << oCamera.Get(vptz::PTZ_CAM_FRAME_POS) <<std::endl;
					break;
				}
					
				
				// Escritura en fichero binario (para que luego lea en C)
				/*FILE * pFile;
				char pathFolderFramesPTZ[100]; 
				sprintf(pathFolderFramesPTZ, "/home/ubuntu/Documentos/BarridoFrames/MatFrame_%06d.bin", nFrameIdx); 
				pFile = fopen(pathFolderFramesPTZ, "wb");			
				
				for(j = 0;j < oCurrView.cols;j++)
				{
					for(i = 0;i < oCurrView.rows;i++)
					{
						cv::Vec4b& bgra = oCurrView.at<cv::Vec4b>(i, j);
						fwrite(&bgra[2], 1, sizeof(u_int8_t), pFile);
						fwrite(&bgra[1], 1, sizeof(u_int8_t), pFile);
						fwrite(&bgra[0], 1, sizeof(u_int8_t), pFile);
						fwrite(&bgra[3], 1, sizeof(u_int8_t), pFile);
					}
				}*/
				
				//fwrite(oCurrView.data, oCurrView.total()*oCurrView.elemSize(), sizeof(u_int8_t), pFile);
				//fclose (pFile);

				
				/*// Prueba de lectura del archivo binario guardado (FUNCIONA!!!)
				size_t lSize;
				char * buffer;
				size_t result;

				pFile = fopen(pathFolderFramesPTZ, "rb");
				if (pFile==NULL) {fputs ("File error",stderr); exit (1);}

				// obtain file size:
				fseek (pFile , 0 , SEEK_END);
				lSize = ftell(pFile);
				rewind (pFile);

				// allocate memory to contain the whole file:
				buffer = (char*) malloc (sizeof(char)*lSize);

				if (buffer == NULL) {fputs ("Memory error",stderr); exit (2);}

				// copy the file into the buffer:
				result = fread(buffer,1,lSize,pFile);
				if (result != lSize) {fputs ("Reading error",stderr); exit (3);}

				// clean up
				fclose (pFile);

				cv::Mat image;
				uint8_t *imageMap = (uint8_t*)buffer;
				image.create(480, 640, CV_8UC4);
				memcpy(image.data, imageMap, 480*640*sizeof(uint8_t)*4);
				
				cv::namedWindow("Copy View");
				cv::imshow("Copy View", image);
				*/

				
				
				/* Read 3D point of the image and transform it to create pano image and save coordinates */

				NdxPixel = 0;
				NdxUx = 0;
				NdxVy = 0;
				for (j = 0; j < oCurrView.cols; j++)
				{
					for (i = 0; i < oCurrView.rows; i++)
					{
						// Save image in the buffer
						cv::Vec4b& bgra = oCurrView.at<cv::Vec4b>(i,j);
						rgb[NdxPixel]=bgra[2];
						rgb[NdxPixel+1]=bgra[1];
						rgb[NdxPixel+2]=bgra[0];
						rgb[NdxPixel+3]=bgra[3];
						NdxPixel = NdxPixel+4;
											
						//Define point
						g_oLastMouseClickPos = cv::Point(j,i);	
	
						//Transform the point to obtain angles
						horiAngle = oCamera.Get(vptz::PTZ_CAM_HORI_ANGLE);
						vertiAngle = oCamera.Get(vptz::PTZ_CAM_VERTI_ANGLE);
						vertiFOV = oCamera.Get(vptz::PTZ_CAM_VERTI_FOV);
						tempHoriAngle = horiAngle;
						tempVertiAngle = vertiAngle;
						vptz::PTZPointXYtoHV(g_oLastMouseClickPos.x, g_oLastMouseClickPos.y, tempHoriAngle, tempVertiAngle, 640, 480, vertiFOV, horiAngle, vertiAngle);
						//obtain3Dpoint(g_oLastMouseClickPos.x, g_oLastMouseClickPos.y, x[k], y[k], z[k], 640, 480, 90.0, horiAngle, vertiAngle);
						
						//Angle normalization
						normHoriAngle = -tempHoriAngle/360.0 + 0.5;
						normVertiAngle = tempVertiAngle/180.0;						
						//std::cout << "Normalized horizontal angle: " << normHoriAngle << std::endl;
						//std::cout << "Normalized vertical angle: " << normVertiAngle << std::endl;
												
						//Update pano image
						cv::Point p = cv::Point((int)(normVertiAngle*panoImage.rows),(int)(normHoriAngle*panoImage.cols));
						Pano.at<cv::Vec4b>(p.x,p.y) = oCurrView.at<cv::Vec4b>(i,j);					
						
						//vptz::PTZPointHVtoXY(tempHoriAngle, tempVertiAngle, px, py, 640, 480, 90.0, horiAngle, vertiAngle);
						//CopyView.at<cv::Vec4b>(py,px) = Pano.at<cv::Vec4b>(p.x,p.y);
				
						//Save horizontal angle
						Ux[NdxUx]=normHoriAngle;
						NdxUx=NdxUx+1;
						//Save vertical angle
						Vy[NdxVy]=normVertiAngle;
						NdxVy=NdxVy+1;
						
					}
					
				}
				
				
				/* Write the binary files */
				FILE * pFile;
				char pathFolderFramesPTZ[100],pathFolderFramesPTZtemp[100]; 
				//sprintf(pathFolderFramesPTZtemp, "/home/ubuntu/Documentos/BarridoFrames/temp.bin");
				sprintf(pathFolderFramesPTZtemp, "/media/sf_CarpetaCompartidaVM/BarridoFrames/temp.bin"); 
				pFile = fopen(pathFolderFramesPTZtemp, "wb");
				
				fwrite(rgb, 1, size1*sizeof(unsigned char), pFile);
				fwrite(Ux, 1, size2*sizeof(double), pFile);
				fwrite(Vy, 1, size3*sizeof(double), pFile);
				
				fclose (pFile);
				
				sprintf(pathFolderFramesPTZ, "/media/sf_CarpetaCompartidaVM/BarridoFrames/MatFrame_%06d.bin", numSamples);
				if(!rename(pathFolderFramesPTZtemp,pathFolderFramesPTZ)==0)// Renombramos el archivo
				{
        			printf("El archivo no se renombro correctamente\n");
					break;
				}

				
				
				/*char pathFolderPanoPTZ[100]; 
				sprintf(pathFolderPanoPTZ, "/home/ubuntu/litiv_vptz_icip2015/scenario3/PruebaPano/in_%06d.png", nFrameIdx); 
				//this works if the folder is manually before created
				std::cout << "Pano: " << pathFolderPanoPTZ << std::endl;
				cv::imwrite(pathFolderPanoPTZ,Pano);*/
				
				//Show panoramic image
				cv::namedWindow("Panoramic View");
				cv::imshow("Panoramic View", Pano);
				
			
				std::cout << "horiAngle: " << double(oCamera.Get(vptz::PTZ_CAM_HORI_ANGLE)) << std::endl;
				
				
				/* Control the motion of the camera */
				if ((oCamera.Get(vptz::PTZ_CAM_HORI_ANGLE)==180) && (oCamera.Get(vptz::PTZ_CAM_VERTI_ANGLE)==180))
					cameraDirection = -1;
				
				if ((oCamera.Get(vptz::PTZ_CAM_HORI_ANGLE)==180) && (oCamera.Get(vptz::PTZ_CAM_VERTI_ANGLE)==0))
					cameraDirection = 1;
				
				moveCameraRight(&oCamera);
				
				if ((oCamera.Get(vptz::PTZ_CAM_HORI_ANGLE)==180) && ((oCamera.Get(vptz::PTZ_CAM_VERTI_ANGLE)>0) || (oCamera.Get(vptz::PTZ_CAM_VERTI_ANGLE)<180)))
				{
					if (cameraDirection == 1)	moveCameraDown(&oCamera);
					else						moveCameraUp(&oCamera);
				}
				
				/* Control the zoom of the camera */
				if(zoomMinR == PTZ_CAM_MIN_VERTI_FOV)
					cameraZoom = 1;
				if(zoomMaxR == PTZ_CAM_MAX_VERTI_FOV)
					cameraZoom = -1;
				
				newVertiFOV = zoomMinR + (cameraZoom)*(double(rand())/RAND_MAX)*PTZ_CAM_ZOOM_RANGE;
				oCamera.Set(vptz::PTZ_CAM_VERTI_FOV, newVertiFOV);
				zoomMinR = zoomMinR+(cameraZoom)*PTZ_CAM_ZOOM_RANGE;
				zoomMaxR = zoomMaxR+(cameraZoom)*PTZ_CAM_ZOOM_RANGE;
				
				

				//Show current view
				cv::imshow("Current View", oCurrView);
				
				//save the frame
				/*
				char pathFolderFramesPTZ[100]; 
				sprintf(pathFolderFramesPTZ, "/home/ubuntu/litiv_vptz_icip2015/scenario3/FramesPTZ/in_%06d.png", nFrameIdx); 
				//this works if the folder is manually before created
				std::cout << "Frame: " << pathFolderFramesPTZ << std::endl;
				cv::imwrite(pathFolderFramesPTZ,oCurrView);
				*/
				
				char cKey = cv::waitKey(1);
				/*if(cKey==' ')
					bPaused = !bPaused;
				else */if(cKey!=-1)
					break;
				if(!bPaused)
					break;
				
				
				
			}
			
			
			//To restart the video
			if (nFrameIdx==oCamera.Get(vptz::PTZ_CAM_FRAME_NUM)-1)
				nFrameIdx=-1;	//Porque antes hace ++nFrameIdx, es decir, lo incrementa y luego compara
			
			if(!oCurrView.empty())
				numSamples++;
			if (numSamples==3000)
				break;
			
        }
		
		
        return 0;
    }
    catch(const std::exception& e) {
        std::cerr << "top level caught std::exception:\n" << e.what() << std::endl;
    }
    catch(...) {
        std::cerr << "top level caught unknown exception." << std::endl;
    }
}
