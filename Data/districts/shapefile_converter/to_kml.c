
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "shapefile_src/shapefil.h"

int main(int argc, char **argv)
{
  if (argc == 1) { printf("usage: shapefile_to_kml [FILENAME]\n"); exit(1); }
  
  DBFHandle d = DBFOpen(argv[1], "rb");
  if (d == NULL) { printf("DBFOpen error (%s.dbf)\n", argv[1]); exit(1); }
	
	SHPHandle h = SHPOpen(argv[1], "rb");
  if (h == NULL) { printf("SHPOpen error (%s.dbf)\n", argv[1]); exit(1); }
	
  char filename[60];
  sprintf(filename, "%s.kml", argv[1]);
  printf("%s\n", filename);
  FILE *fp = fopen(filename, "w");
  if (fp == NULL) { printf("fopen error\n"); exit(1); }
	
  int nRecordCount = DBFGetRecordCount(d);
  int nFieldCount = DBFGetFieldCount(d);
  printf("DBF has %d records (with %d fields)\n", nRecordCount, nFieldCount);
	
  fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(fp, "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n");

  /*for (int i = 0 ; i < nFieldCount ; i++)
  {
    char pszFieldName[12];
    int pnWidth;
    int pnDecimals;
    DBFFieldType ft = DBFGetFieldInfo(d, i, pszFieldName, &pnWidth, &pnDecimals);
    switch (ft)
    {
      case FTString:
        fprintf(fp, ", %s VARCHAR(%d)", pszFieldName, pnWidth);
        break;
      case FTInteger:
        fprintf(fp, ", %s INT", pszFieldName);
        break;
      case FTDouble:
        fprintf(fp, ", %s FLOAT(15,10)", pszFieldName);
        break;
      case FTLogical:
        break;
      case FTInvalid:
        break;
    }
  }*/
  
  fprintf(fp, "  <Document>\n");
  int i;
  for (i = 0 ; i < nRecordCount ; i++)
  {
    fprintf(fp, "    <Placemark>\n");
    fprintf(fp, "      <name>%s</name>\n", (char *)DBFReadStringAttribute(d, i, 2));
    fprintf(fp, "      <Polygon>\n");
    fprintf(fp, "        <extrude>1</extrude>\n");
    fprintf(fp, "        <altitudeMode>relativeToGround</altitudeMode>\n");
    fprintf(fp, "        <outerBoundaryIs>\n");
    fprintf(fp, "          <LinearRing>\n");
    fprintf(fp, "            <coordinates>\n");
    
    SHPObject	*psShape = SHPReadObject(h, i);
    int j, iPart;
    for (j = 0, iPart = 1; j < psShape->nVertices; j++)
    {
      fprintf(fp, "%f,%f,100\n", psShape->padfX[j], psShape->padfY[j]);
    }
    
    fprintf(fp, "            </coordinates>\n");
    fprintf(fp, "          </LinearRing>\n");
    fprintf(fp, "        </outerBoundaryIs>\n");
    fprintf(fp, "      </Polygon>\n");
    fprintf(fp, "    </Placemark>\n");
  }
  fprintf(fp, "  </Document>\n");
	
  /*int nShapeType;
  int nEntities;
  const char *pszPlus;
  double adfMinBound[4], adfMaxBound[4];
	
  SHPGetInfo(h, &nEntities, &nShapeType, adfMinBound, adfMaxBound);
  printf("SHP has %d entities\n", nEntities);
  
  for (i = 0; i < nEntities; i++)
  {
    SHPObject	*psShape = SHPReadObject(h, i);
    
    //fprintf(fp, "INSERT INTO edges (id) VALUES (%d);\n", i+1);
    
    int j, iPart;
    for (j = 0, iPart = 1; j < psShape->nVertices; j++)
    {
      const char *pszPartType = "";
      
      if (j == 0 && psShape->nParts > 0) pszPartType = SHPPartTypeName(psShape->panPartType[0]);
      if (iPart < psShape->nParts && psShape->panPartStart[iPart] == j)
      {
        pszPartType = SHPPartTypeName(psShape->panPartType[iPart]);
        iPart++;
        pszPlus = "+";
      }
      else
        pszPlus = " ";
      
      //if (j%500==0)
      //  fprintf(fp, "%sINSERT INTO vertexes (edge_id, x, y) VALUES (", (j!=0 ? ");\n": ""));
      //else
      //  fprintf(fp, "),(");
      
      //fprintf(fp, "%d, %f, %f", i+1, psShape->padfX[j], psShape->padfY[j]);
    }
    //fprintf(fp, ");\n");
    
    SHPDestroyObject(psShape);
  }*/
  
  fprintf(fp, "</kml>\n");
	printf("all done\n");
  
  fclose(fp);
  
	if (h != NULL) SHPClose(h);
	if (d != NULL) DBFClose(d);
}