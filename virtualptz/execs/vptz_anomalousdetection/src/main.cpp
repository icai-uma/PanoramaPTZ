
//======================================================================================
//
// This program is used to view ground truth annotations while controlling the camera.
//
// Before running, set the input scenario/gt paths using the defines below.
//
//======================================================================================

#include "litiv/vptz/virtualptz.hpp"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define INPUT_SCENARIO_PATH        "/home/ubuntu/litiv_vptz_icip2015/scenario3/scenario3.avi"
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
#define PTZ_CAM_MIN_VERTI_FOV  40 // no specified
#define PTZ_CAM_MAX_VERTI_FOV  140 // no specified

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cv::Point g_oLastMouseClickPos;/*
void onMouse(int nEventCode, int x, int y, int, void*) {
    if(nEventCode==cv::EVENT_LBUTTONDOWN) {
        std::cout << "Clicked at [" << x << "," << y << "]" << std::endl;
        g_oLastMouseClickPos = cv::Point(x,y);
    }
}*/

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

void moveCameraZoomIn(vptz::Camera * oCamera){
	int vertiFOVTemp = int(oCamera->Get(vptz::PTZ_CAM_VERTI_FOV)); 
	int vertiFOV = vertiFOVTemp;
	vertiFOV = vertiFOVTemp - PTZ_CAM_ZOOM_MOVE; //zoom in
	if(vertiFOV>=PTZ_CAM_MIN_VERTI_FOV && vertiFOV<=PTZ_CAM_MAX_VERTI_FOV){ //we update the zoom if it is between the valid values
		oCamera->Set(vptz::PTZ_CAM_VERTI_FOV, vertiFOV);
	}
}

void moveCameraZoomOut(vptz::Camera * oCamera){
	int vertiFOVTemp = int(oCamera->Get(vptz::PTZ_CAM_VERTI_FOV));
	int vertiFOV = vertiFOVTemp;
	vertiFOV = vertiFOVTemp + PTZ_CAM_ZOOM_MOVE; //zoom out
	if(vertiFOV>=PTZ_CAM_MIN_VERTI_FOV && vertiFOV<=PTZ_CAM_MAX_VERTI_FOV){ //we update the zoom if it is between the valid values
		oCamera->Set(vptz::PTZ_CAM_VERTI_FOV, vertiFOV);
	}
}

void moveCamera(vptz::Camera * oCamera, cv::Mat oCurrView,cv::Point oTargetPos_XY){ ///////////////eliminar param oTargetPos_XY
	bool targetFound = false;
	int oTargetZoom = -1;
	
	
	//to detect objects
	/////TO DO
	
	//if there is a target, its position is saved on oTargetPos_XY and if we need to do zoom this is saved on oTargetZoom	oTargetZoom=1 -> zoom out
	//																														oTargetZoom=0 -> no zoom
	//																														oTargetZoom=-1 -> zoom in
	//std::cout << "TargetXY on " << oTargetPos_XY << std::endl;
	int frameWidth = 640;
	int frameHeight = 480;

	if(oTargetPos_XY.x<0 || oTargetPos_XY.x>frameWidth || oTargetPos_XY.y<0 || oTargetPos_XY.y>frameHeight){
		//std::cout << "Target out" << std::endl;
		targetFound = false;
	}else{
		//std::cout << "Target in" << std::endl;
		targetFound = true;
	}
	
	if(!targetFound){ //camera searching		 
		moveCameraRight(oCamera); //move right
	}else{ //camera following the target		
		if((oCurrView.cols/2-oTargetPos_XY.x) < -PTZ_CAM_HORI_VERTI_MOVE_PIXELS){ //target to the right and the distance to it its higher than a cam movement (in pixels) in a frame			
			moveCameraRight(oCamera); //move right
		}else if((oCurrView.cols/2-oTargetPos_XY.x) > PTZ_CAM_HORI_VERTI_MOVE_PIXELS){ 			
			moveCameraLeft(oCamera); //move left
		}

		std::cout << "dif col target: " << oCurrView.rows/2-oTargetPos_XY.y << std::endl;
		if((oCurrView.rows/2-oTargetPos_XY.y) < -PTZ_CAM_HORI_VERTI_MOVE_PIXELS*2){ //target to the down //we let lower sensitive than horizontal move multiplying x 2
			moveCameraDown(oCamera); //move down
		}else if((oCurrView.rows/2-oTargetPos_XY.y) > PTZ_CAM_HORI_VERTI_MOVE_PIXELS*2){ 
			moveCameraUp(oCamera); //move up
		}
		
		if(oTargetZoom==1){ //target big, so we want to do zoom out
			moveCameraZoomOut(oCamera); //zoom out
		}else if(oTargetZoom==-1){ //target small, so we want to do zoom in
			moveCameraZoomIn(oCamera); //zoom in
		}
		
	}
	
	
	
	//g_oLastMouseClickPos = cv::Point(oCurrView.cols/2+moveCol, oCurrView.rows/2+moveRow);
}



int main(int /*argc*/, char** /*argv*/) {
    try {
        cv::FileStorage oInputGT(INPUT_GT_SEQUENCE_PATH, cv::FileStorage::READ);
        int nGTFrameWidth = oInputGT["frameImageWidth"];
        int nGTFrameHeight = oInputGT["frameImageHeight"];
        double dGTVerticalFOV = oInputGT["verticalFOV"];
		
        vptz::Camera oCamera(INPUT_SCENARIO_PATH);
        vptz::GTTranslator oGTTranslator(&oCamera, nGTFrameWidth, nGTFrameHeight, dGTVerticalFOV);
        cv::Point oTargetPos_XY;
        cv::Point2d oTargetPos_HX;
        cv::Mat oCurrView;
        //int nBBoxWidth, nBBoxHeight;
        int nFrameIdx;

        oCamera.Set(vptz::PTZ_CAM_FRAME_POS, 0);
        oCurrView = oCamera.GetFrame();
        cv::namedWindow("Current View");
        cv::imshow("Current View", oCurrView);
        cv::waitKey(1);
        //cv::setMouseCallback("Current View", onMouse, 0);
		
        g_oLastMouseClickPos = cv::Point(oCurrView.cols/2, oCurrView.rows/2);		
		

        cv::FileNode oGTNode = oInputGT["basicGroundTruth"];
		bool bPaused = false;
        for(auto oGTFrame=oGTNode.begin(); oGTFrame!=oGTNode.end(); ++oGTFrame) {
            nFrameIdx = (*oGTFrame)["framePos"];
            //nBBoxWidth = (*oGTFrame)["width"];
            //nBBoxHeight = (*oGTFrame)["height"];
            oTargetPos_HX.x = (*oGTFrame)["horizontalAngle"];
            oTargetPos_HX.y = (*oGTFrame)["verticalAngle"];
			std::cout << "\t#" << nFrameIdx << std::endl;
            oCamera.Set(vptz::PTZ_CAM_FRAME_POS, nFrameIdx);
			

			
			while(true) {
				
				
				
				oCamera.GoToPosition(g_oLastMouseClickPos);
				oCurrView = oCamera.GetFrame();

				if(oCurrView.empty())
					break;
						
				
				//cv::circle(oCurrView, cv::Point(oCurrView.cols/2,oCurrView.rows/2), 3, cv::Scalar(0,255,0), 5); //draw camera centroid
				
				oGTTranslator.GetGTTargetPoint(oTargetPos_HX.x, oTargetPos_HX.y, oTargetPos_XY);
				cv::circle(oCurrView, oTargetPos_XY, 3, cv::Scalar(0,255,255), 5); //draw target centroid
				
				//draw bounding box of the target
				/*
				cv::Rect bb;
				oGTTranslator.GetGTBoundingBox(oTargetPos_HX.x, oTargetPos_HX.y, nBBoxWidth, nBBoxHeight, bb);
				cv::rectangle(oCurrView, bb, cv::Scalar(0,255,255));
				*/
				moveCamera(&oCamera,oCurrView,oTargetPos_XY); //quitar el ultimo parametro (se obtiene dentro del metodo despues del deep learning)
				
		
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
